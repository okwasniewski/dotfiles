#!/usr/bin/env node
// Read-only: lists open PRs that look ready to merge. Never writes to GitHub.
// Usage: ready-prs.mjs [owner/repo ...] [--json]
import { execFileSync } from "node:child_process";

const TEAM = new Set(["OWNER", "MEMBER", "COLLABORATOR"]);
const MERGEABLE = new Set(["CLEAN", "UNSTABLE", "HAS_HOOKS"]);
const CODEX_BOT = "chatgpt-codex-connector";
const CUBIC_BOT = "cubic-dev-ai";
const CUBIC_CLEAN = /no issues found|\b0 issues found|all reported issues were addressed/i;
const MERGE_BLOCKER = {
  DIRTY: "merge conflicts",
  BEHIND: "behind base branch",
  BLOCKED: "blocked by branch rules",
  UNKNOWN: "merge state not computed yet",
};

const PR_FIELDS = `
  number title url isDraft createdAt updatedAt additions deletions
  baseRefName headRefName headRefOid mergeStateStatus reviewDecision
  author { login __typename } authorAssociation
  commits(last: 1) { nodes { commit { statusCheckRollup { state } } } }
  reviewThreads(first: 100) { nodes { isResolved } }
  reviews(last: 30) { nodes { author { login } state body commit { oid } } }
  reactions(content: THUMBS_UP, first: 50) { nodes { user { login } } }
`;

function gh(args) {
  return execFileSync("gh", args, { encoding: "utf8", maxBuffer: 64 << 20, stdio: ["ignore", "pipe", "pipe"] });
}

function graphql(query, vars) {
  const args = ["api", "graphql", "-f", `query=${query}`];
  for (const [k, v] of Object.entries(vars)) {
    args.push(typeof v === "number" ? "-F" : "-f", `${k}=${v}`);
  }
  return JSON.parse(gh(args)).data;
}

function listOpen(owner, name) {
  const prs = [];
  let after = null;
  do {
    const data = graphql(
      `query($owner: String!, $name: String!, $after: String) {
        repository(owner: $owner, name: $name) {
          pullRequests(states: OPEN, first: 40, after: $after, orderBy: {field: UPDATED_AT, direction: DESC}) {
            pageInfo { hasNextPage endCursor }
            nodes { ${PR_FIELDS} }
          }
        }
      }`,
      after ? { owner, name, after } : { owner, name },
    );
    const page = data.repository.pullRequests;
    prs.push(...page.nodes);
    after = page.pageInfo.hasNextPage ? page.pageInfo.endCursor : null;
  } while (after);
  return prs;
}

// GitHub computes mergeStateStatus lazily and the list query often says UNKNOWN.
function refreshUnknown(owner, name, prs) {
  for (let attempt = 0; attempt < 3; attempt++) {
    const unknown = prs.filter((pr) => !pr.isDraft && pr.mergeStateStatus === "UNKNOWN");
    if (!unknown.length) return;
    if (attempt) execFileSync("sleep", ["3"]);
    for (const pr of unknown) {
      const data = graphql(
        `query($owner: String!, $name: String!, $number: Int!) {
          repository(owner: $owner, name: $name) { pullRequest(number: $number) { mergeStateStatus } }
        }`,
        { owner, name, number: pr.number },
      );
      pr.mergeStateStatus = data.repository.pullRequest.mergeStateStatus;
    }
  }
}

const isBot = (login, bot) => login === bot || login === `${bot}[bot]`;

function botVerdict(pr) {
  if (pr.reactions.nodes.some((r) => isBot(r.user?.login, CODEX_BOT))) return "codex +1";
  const cubic = pr.reviews.nodes.filter((r) => isBot(r.author?.login, CUBIC_BOT) && /issue/i.test(r.body));
  const last = cubic.at(-1);
  if (!last) return null;
  if (!CUBIC_CLEAN.test(last.body)) return "cubic: issues";
  return last.commit?.oid === pr.headRefOid ? "cubic clean" : "cubic clean (older commit)";
}

function groupOf(pr) {
  if (pr.author?.__typename === "Bot") return "bot";
  return TEAM.has(pr.authorAssociation) ? "team" : "community";
}

function assess(pr, repoUsesBot) {
  const group = groupOf(pr);
  const ci = pr.commits.nodes[0]?.commit.statusCheckRollup?.state ?? "NONE";
  const unresolved = pr.reviewThreads.nodes.filter((t) => !t.isResolved).length;
  const bot = botVerdict(pr);
  const blockers = [];
  // BLOCKED with REVIEW_REQUIRED only waits on the approval this list is meant to prompt.
  const awaitsApproval = pr.mergeStateStatus === "BLOCKED" && pr.reviewDecision === "REVIEW_REQUIRED";
  if (!MERGEABLE.has(pr.mergeStateStatus) && !awaitsApproval) blockers.push(MERGE_BLOCKER[pr.mergeStateStatus] ?? `merge state ${pr.mergeStateStatus}`);
  if (ci === "FAILURE" || ci === "ERROR") blockers.push("CI failing");
  if (ci === "PENDING" || ci === "EXPECTED") blockers.push("CI running");
  if (pr.reviewDecision === "CHANGES_REQUESTED") blockers.push("changes requested");
  if (unresolved) blockers.push(`${unresolved} unresolved thread${unresolved > 1 ? "s" : ""}`);
  if (bot === "cubic: issues") blockers.push("bot found issues");
  if (bot === null && repoUsesBot && group !== "bot") blockers.push("no bot review yet");
  return {
    number: pr.number,
    title: pr.title,
    url: pr.url,
    author: pr.author?.login ?? "ghost",
    group,
    association: pr.authorAssociation,
    mergeState: pr.mergeStateStatus,
    ci,
    reviewDecision: pr.reviewDecision ?? "NONE",
    unresolved,
    bot: bot ?? "none",
    size: `+${pr.additions}/-${pr.deletions}`,
    updated: pr.updatedAt.slice(0, 10),
    blockers,
  };
}

function table(rows) {
  const lines = ["| PR | Author | Size | CI | Bot | Review | Updated |", "| --- | --- | --- | --- | --- | --- | --- |"];
  for (const r of rows) {
    const title = r.title.replaceAll("|", "\\|");
    lines.push(`| [#${r.number}](${r.url}) ${title} | ${r.author} | ${r.size} | ${r.ci} | ${r.bot} | ${r.reviewDecision} | ${r.updated} |`);
  }
  return lines.join("\n");
}

function report(repo, results) {
  const ready = results.filter((r) => !r.blockers.length);
  const close = results.filter((r) => r.blockers.length === 1);
  const out = [`## ${repo}`, "", `${results.length} open non-draft PRs, ${ready.length} ready, ${close.length} one step away.`];
  for (const group of ["team", "community", "bot"]) {
    const rows = ready.filter((r) => r.group === group);
    if (group === "bot" && !rows.length) continue;
    out.push("", `### Ready: ${group} (${rows.length})`, "", rows.length ? table(rows) : "None.");
  }
  if (close.length) {
    out.push("", `### One step away (${close.length})`, "");
    for (const r of close) out.push(`- [#${r.number}](${r.url}) ${r.title} (${r.author}, ${r.group}): ${r.blockers[0]}`);
  }
  return out.join("\n");
}

function main() {
  const args = process.argv.slice(2);
  const asJson = args.includes("--json");
  let repos = args.filter((a) => !a.startsWith("--"));
  if (!repos.length) repos = [gh(["repo", "view", "--json", "nameWithOwner", "--jq", ".nameWithOwner"]).trim()];

  const all = {};
  for (const repo of repos) {
    const [owner, name] = repo.split("/");
    if (!owner || !name) throw new Error(`expected owner/repo, got "${repo}"`);
    const prs = listOpen(owner, name).filter((pr) => !pr.isDraft);
    refreshUnknown(owner, name, prs);
    const repoUsesBot = prs.some((pr) => botVerdict(pr) !== null);
    all[repo] = prs.map((pr) => assess(pr, repoUsesBot));
  }

  if (asJson) console.log(JSON.stringify(all, null, 2));
  else console.log(Object.entries(all).map(([repo, results]) => report(repo, results)).join("\n\n"));
}

try {
  main();
} catch (error) {
  const detail = error.stderr?.toString().trim() || error.message;
  console.error(`ready-prs: ${detail}`);
  process.exit(1);
}
