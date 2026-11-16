#!/usr/bin/env node
// Read-only second-pass queue: open PRs that look ready for a human to merge.
// Never writes to GitHub.
// Usage: ready-prs.mjs [owner/repo ...] [--label "<name>" | --label none] [--json]
import { execFileSync } from "node:child_process";

const TEAM = new Set(["OWNER", "MEMBER", "COLLABORATOR"]);
const MERGEABLE = new Set(["CLEAN", "UNSTABLE", "HAS_HOOKS"]);
const CODEX_BOT = "chatgpt-codex-connector";
const CUBIC_BOT = "cubic-dev-ai";
const CUBIC_CLEAN = /no issues found|\b0 issues found|all reported issues were addressed/i;
const READY_LABEL = /^ready for (human|maintainer) review$/i;
const AUTOMATED_REVIEW = /automated review/i;
const STALE_DAYS = 14;
const DAY = 86_400_000;
// Files nearly every PR touches; sharing them is not a real overlap.
const OVERLAP_IGNORE = /(^|\/)(pnpm-lock\.yaml|package-lock\.json|yarn\.lock|bun\.lockb?|CHANGELOG\.md)$|^\.changeset\//;
const MERGE_BLOCKER = {
  DIRTY: "merge conflicts",
  BEHIND: "behind base branch",
  BLOCKED: "blocked by branch rules",
  UNKNOWN: "merge state not computed yet",
};

const PR_FIELDS = `
  number title url isDraft createdAt updatedAt additions deletions
  headRefOid mergeStateStatus reviewDecision
  author { login __typename } authorAssociation
  labels(first: 30) { nodes { name } }
  files(first: 100) { nodes { path } }
  commits(last: 1) { nodes { commit { committedDate statusCheckRollup { state } } } }
  timelineItems(itemTypes: [LABELED_EVENT], last: 20) { nodes { ... on LabeledEvent { createdAt label { name } } } }
  reviewThreads(first: 100) { nodes { isResolved } }
  latestReviews(first: 50) { nodes { author { login } state } }
  reviews(last: 30) { nodes { author { login } state body url commit { oid } } }
  comments(last: 30) { nodes { body url } }
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
          pullRequests(states: OPEN, first: 25, after: $after, orderBy: {field: UPDATED_AT, direction: DESC}) {
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

function findReadyLabel(owner, name) {
  const data = graphql(
    `query($owner: String!, $name: String!) {
      repository(owner: $owner, name: $name) { labels(first: 20, query: "review") { nodes { name } } }
    }`,
    { owner, name },
  );
  return data.repository.labels.nodes.map((l) => l.name).find((n) => READY_LABEL.test(n)) ?? null;
}

// GitHub computes mergeStateStatus lazily and the list query often says UNKNOWN.
function refreshUnknown(owner, name, prs) {
  for (let attempt = 0; attempt < 3; attempt++) {
    const unknown = prs.filter((pr) => pr.mergeStateStatus === "UNKNOWN");
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

function latestAutomatedReview(pr) {
  const hits = [...pr.reviews.nodes, ...pr.comments.nodes].filter((n) => AUTOMATED_REVIEW.test(n.body ?? ""));
  return hits.at(-1)?.url ?? null;
}

function labelState(pr, label) {
  if (!label) return { labeled: true, pushedAfter: false };
  if (!pr.labels.nodes.some((l) => l.name === label)) return { labeled: false, pushedAfter: false };
  const labeledAt = pr.timelineItems.nodes.filter((e) => e.label?.name === label).at(-1)?.createdAt;
  const committedAt = pr.commits.nodes[0]?.commit.committedDate;
  return { labeled: true, pushedAfter: Boolean(labeledAt && committedAt && committedAt > labeledAt) };
}

function assess(pr, { repoUsesBot, label, now }) {
  const group = groupOf(pr);
  const author = pr.author?.login ?? "ghost";
  const ci = pr.commits.nodes[0]?.commit.statusCheckRollup?.state ?? "NONE";
  const unresolved = pr.reviewThreads.nodes.filter((t) => !t.isResolved).length;
  const others = pr.latestReviews.nodes.filter((r) => r.author && r.author.login !== author);
  const changesBy = others.filter((r) => r.state === "CHANGES_REQUESTED").map((r) => r.author.login);
  const approvedBy = others.filter((r) => r.state === "APPROVED").map((r) => r.author.login);
  const bot = botVerdict(pr);
  const { labeled, pushedAfter } = labelState(pr, label);
  const blockers = [];
  // BLOCKED with REVIEW_REQUIRED only waits on the approval this list is meant to prompt.
  const awaitsApproval = pr.mergeStateStatus === "BLOCKED" && pr.reviewDecision === "REVIEW_REQUIRED";
  if (!MERGEABLE.has(pr.mergeStateStatus) && !awaitsApproval) blockers.push(MERGE_BLOCKER[pr.mergeStateStatus] ?? `merge state ${pr.mergeStateStatus}`);
  if (ci === "NONE") blockers.push("no CI ran");
  if (ci === "FAILURE" || ci === "ERROR") blockers.push("CI failing");
  if (ci === "PENDING" || ci === "EXPECTED") blockers.push("CI running");
  if (changesBy.length) blockers.push(`changes requested by ${changesBy.join(", ")}`);
  if (unresolved) blockers.push(`${unresolved} unresolved thread${unresolved > 1 ? "s" : ""}`);
  if (bot === "cubic: issues") blockers.push("bot found issues");
  // With a ready label, the first-pass review is the gate and the bot only informs.
  if (bot === null && repoUsesBot && group !== "bot" && !label) blockers.push("no bot review yet");
  if (!labeled && group !== "bot") blockers.push(`no "${label}" label yet`);
  if (pushedAfter) blockers.push(`new commits after "${label}"`);
  const idleDays = Math.floor((now - Date.parse(pr.updatedAt)) / DAY);
  return {
    number: pr.number,
    title: pr.title,
    url: pr.url,
    author,
    group,
    association: pr.authorAssociation,
    mergeState: pr.mergeStateStatus,
    ci,
    bot: bot ?? "none",
    approvedBy,
    automatedReview: latestAutomatedReview(pr),
    lines: pr.additions + pr.deletions,
    size: `+${pr.additions}/-${pr.deletions}`,
    ageDays: Math.floor((now - Date.parse(pr.createdAt)) / DAY),
    idleDays,
    stale: idleDays >= STALE_DAYS,
    files: pr.files.nodes.map((f) => f.path).filter((p) => !OVERLAP_IGNORE.test(p)),
    blockers,
  };
}

// Release bots touch every package, so they would overlap everything.
function addOverlaps(rows) {
  const humans = rows.filter((r) => r.group !== "bot");
  for (const r of humans) {
    const mine = new Set(r.files);
    r.overlapsWith = humans.filter((o) => o !== r && o.files.some((f) => mine.has(f))).map((o) => o.number);
  }
}

function notes(r) {
  const out = [];
  if (r.approvedBy.length) out.push(`approved by ${r.approvedBy.join(", ")}`);
  if (r.bot === "cubic clean (older commit)") out.push("bot passed an older commit");
  if (r.bot === "none" && r.group !== "bot") out.push("no bot review");
  if (r.overlapsWith?.length) out.push(`same files as ${r.overlapsWith.map((n) => `#${n}`).join(", ")}`);
  if (r.stale) out.push(`idle ${r.idleDays}d`);
  return out.join("; ");
}

function table(rows) {
  const lines = ["| PR | Author | Size | Age | Agent review | Notes |", "| --- | --- | --- | --- | --- | --- |"];
  for (const r of rows) {
    const title = r.title.replaceAll("|", "\\|");
    const review = r.automatedReview ? `[latest](${r.automatedReview})` : "none";
    lines.push(`| [#${r.number}](${r.url}) ${title} | ${r.author} | ${r.size} | ${r.ageDays}d | ${review} | ${notes(r)} |`);
  }
  return lines.join("\n");
}

function report(repo, label, results) {
  const ready = results.filter((r) => !r.blockers.length).sort((a, b) => a.lines - b.lines || b.ageDays - a.ageDays);
  addOverlaps(ready);
  const close = results.filter((r) => r.blockers.length === 1).sort((a, b) => b.ageDays - a.ageDays);
  const gate = label ? `, gated on the "${label}" label` : "";
  const out = [
    `## ${repo}`,
    "",
    `${results.length} open non-draft PRs${gate}: ${ready.length} ready, ${close.length} one step away. Smallest first.`,
  ];
  for (const group of ["team", "community", "bot"]) {
    const rows = ready.filter((r) => r.group === group);
    if (group === "bot" && !rows.length) continue;
    out.push("", `### Ready: ${group} (${rows.length})`, "", rows.length ? table(rows) : "None.");
  }
  if (close.length) {
    out.push("", `### One step away (${close.length})`, "");
    for (const r of close) out.push(`- [#${r.number}](${r.url}) ${r.title} (${r.author}, ${r.group}, ${r.ageDays}d): ${r.blockers[0]}`);
  }
  return out.join("\n");
}

function parseArgs(argv) {
  const opts = { json: false, label: undefined, repos: [] };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--json") opts.json = true;
    else if (a === "--label") {
      opts.label = argv[++i];
      if (!opts.label || opts.label.startsWith("--")) throw new Error("--label needs a name, or none");
    }
    else if (a.startsWith("--")) throw new Error(`unknown flag ${a}`);
    else opts.repos.push(a);
  }
  return opts;
}

function main() {
  const opts = parseArgs(process.argv.slice(2));
  if (!opts.repos.length) opts.repos = [gh(["repo", "view", "--json", "nameWithOwner", "--jq", ".nameWithOwner"]).trim()];
  const now = Date.now();
  const all = {};
  const sections = [];
  for (const repo of opts.repos) {
    const [owner, name] = repo.split("/");
    if (!owner || !name) throw new Error(`expected owner/repo, got "${repo}"`);
    const label = opts.label === "none" ? null : (opts.label ?? findReadyLabel(owner, name));
    const prs = listOpen(owner, name).filter((pr) => !pr.isDraft);
    refreshUnknown(owner, name, prs);
    const repoUsesBot = prs.some((pr) => botVerdict(pr) !== null);
    const results = prs.map((pr) => assess(pr, { repoUsesBot, label, now }));
    all[repo] = { label, prs: results };
    sections.push(report(repo, label, results));
  }
  console.log(opts.json ? JSON.stringify(all, null, 2) : sections.join("\n\n"));
}

try {
  main();
} catch (error) {
  const detail = error.stderr?.toString().trim() || error.message;
  console.error(`ready-prs: ${detail}`);
  process.exit(1);
}
