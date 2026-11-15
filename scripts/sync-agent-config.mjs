#!/usr/bin/env node
// Generates per-tool agent config from the shared sources in .agents/:
// MCP servers from .agents/mcp.json, commands and skills as symlinks.
// With --check, writes nothing and exits 1 on drift.
import { lstatSync, readFileSync, readlinkSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const check = process.argv.includes("--check");
const read = (path) => readFileSync(join(root, path), "utf8");
const servers = JSON.parse(read(".agents/mcp.json"));
const each = (toEntry) => Object.fromEntries(Object.entries(servers).map(([name, s]) => [name, toEntry(s)]));
const json = (value) => `${JSON.stringify(value, null, 2)}\n`;

const files = {
  ".config/opencode/opencode.json": (text) =>
    json({ ...JSON.parse(text), mcp: each((s) => ({ type: "remote", url: s.url, enabled: true })) }),
  ".config/mcp-config.json": () => json({ mcpServers: each((s) => ({ type: "http", url: s.url, tools: ["*"] })) }),
  ".config/zed/settings.json": (text) =>
    replaceObject(text, "context_servers", each((s) => ({ enabled: true, url: s.url }))),
};

const links = {
  ".claude/commands": "../.agents/commands",
  ".claude/skills": "../.agents/skills",
  ".config/opencode/command": "../../.agents/commands",
  ".config/opencode/skills": "../../.agents/skills",
};

const drift = [];
for (const [path, generate] of Object.entries(files)) {
  const current = read(path);
  const next = generate(current);
  if (next === current) continue;
  drift.push(path);
  if (!check) writeFileSync(join(root, path), next);
}
for (const [path, target] of Object.entries(links)) {
  if (linkTarget(join(root, path)) === target) continue;
  drift.push(`${path} -> ${target}`);
  if (!check) {
    rmSync(join(root, path), { recursive: true, force: true });
    symlinkSync(target, join(root, path));
  }
}

if (drift.length === 0) console.log("agent config in sync");
else if (check) {
  console.error(`agent config drifted from .agents/, run scripts/sync-agent-config.mjs:\n  ${drift.join("\n  ")}`);
  process.exit(1);
} else console.log(`updated:\n  ${drift.join("\n  ")}`);

/** Symlink target of path, or null when it is missing or not a symlink. */
function linkTarget(path) {
  try {
    return lstatSync(path).isSymbolicLink() ? readlinkSync(path) : null;
  } catch {
    return null;
  }
}

/**
 * Swaps the value of a top-level object key in hand-formatted JSON, keeping
 * the rest of the file byte for byte. Entries are written one per line.
 */
function replaceObject(text, key, value) {
  const start = text.indexOf("{", text.indexOf(`"${key}"`));
  if (text.indexOf(`"${key}"`) === -1 || start === -1) throw new Error(`"${key}" not found`);
  let depth = 0;
  let inString = false;
  let end = start;
  for (; end < text.length; end++) {
    const c = text[end];
    if (inString) {
      if (c === "\\") end++;
      else if (c === '"') inString = false;
    } else if (c === '"') inString = true;
    else if (c === "{") depth++;
    else if (c === "}" && --depth === 0) break;
  }
  const inline = (o) => `{ ${Object.entries(o).map(([k, v]) => `${JSON.stringify(k)}: ${JSON.stringify(v)}`).join(", ")} }`;
  const body = Object.entries(value).map(([k, v]) => `    ${JSON.stringify(k)}: ${inline(v)}`);
  return `${text.slice(0, start)}{\n${body.join(",\n")}\n  }${text.slice(end + 1)}`;
}
