#!/usr/bin/env node
// Claude Code PreToolUse(Bash): block npm/yarn/pnpm/bun when the project's lockfile belongs to another manager.
import { existsSync, readFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";

const LOCKFILES = {
  "package-lock.json": "npm",
  "yarn.lock": "yarn",
  "pnpm-lock.yaml": "pnpm",
  "bun.lock": "bun",
  "bun.lockb": "bun",
};
const PROJECT_SUBCOMMANDS = new Set(
  "install i ci add remove rm uninstall un update up upgrade run run-script exec dlx x link".split(" "),
);

const input = JSON.parse(readFileSync(0, "utf8"));
let cwd = input.cwd ?? process.cwd();

for (const segment of (input.tool_input?.command ?? "").split(/&&|\|\||[;|\n]/)) {
  const words = segment.trim().split(/\s+/).filter((w) => !/^\w+=/.test(w));
  const [tool, ...args] = words;
  if (tool === "cd" && args[0]) cwd = resolve(cwd, args[0].replace(/^~/, process.env.HOME));
  if (!["npm", "yarn", "pnpm", "bun"].includes(tool)) continue;
  if (args.some((a) => a === "-g" || a === "--global") || args[0] === "global") continue;
  const sub = args.find((a) => !a.startsWith("-"));
  if (!(sub === undefined ? tool === "yarn" : PROJECT_SUBCOMMANDS.has(sub))) continue;

  const found = nearestLockfiles(cwd);
  if (found.length && !found.some(([, pm]) => pm === tool)) {
    const names = found.map(([file]) => file).join(", ");
    console.error(`This project uses ${found[0][1]} (${names}). Run it with ${found[0][1]} instead of ${tool}.`);
    process.exit(2);
  }
}

/** Lockfiles in the closest directory that has any, stopping at the git root. */
function nearestLockfiles(start) {
  for (let dir = start; ; dir = dirname(dir)) {
    const found = Object.entries(LOCKFILES).filter(([file]) => existsSync(join(dir, file)));
    if (found.length || existsSync(join(dir, ".git")) || dir === dirname(dir)) return found;
  }
}
