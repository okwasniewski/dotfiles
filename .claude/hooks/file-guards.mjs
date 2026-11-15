#!/usr/bin/env node
// Claude Code PreToolUse(Write|Edit|MultiEdit): block edits that push a source
// file past 1000 lines or add a TypeScript `any`.
import { existsSync, readFileSync } from "node:fs";
import { extname } from "node:path";

const MAX_LINES = 1000;
const SOURCE = /\.(?:[cm]?[jt]sx?|swift|kt|java|mm?|h|cc|cpp|py|rb|go|rs)$/;
const TYPESCRIPT = /\.[cm]?tsx?$/;
const ANY = /:\s*any\b(?!\s*[\w$])|\bas\s+any\b|<\s*any\s*[,>]|,\s*any\s*>|\bany\s*\[\]|\|\s*any\b|\bany\s*\|/g;

const { tool_name: tool, tool_input: input } = JSON.parse(readFileSync(0, "utf8"));
const path = input?.file_path;
if (!path || !SOURCE.test(path)) process.exit(0);

const before = existsSync(path) ? readFileSync(path, "utf8") : "";
const after = apply(before);
if (after === null) process.exit(0);

const problems = [];
const lines = (text) => text.split("\n").length - (text.endsWith("\n") ? 1 : 0);
if (lines(before) <= MAX_LINES && lines(after) > MAX_LINES) {
  problems.push(`${path} would grow to ${lines(after)} lines (limit ${MAX_LINES}). Split it into focused modules first.`);
}
const anyCount = (text) => text.match(ANY)?.length ?? 0;
if (TYPESCRIPT.test(extname(path)) && anyCount(after) > anyCount(before)) {
  problems.push(`${path}: the edit adds \`any\`. Use a real type, a generic, or \`unknown\` narrowed at the boundary.`);
}
if (problems.length) {
  console.error(problems.join("\n"));
  process.exit(2);
}

/** File content after the tool runs, or null when the edit would fail anyway. */
function apply(text) {
  if (tool === "Write") return input.content ?? "";
  const edits = tool === "MultiEdit" ? input.edits : [input];
  for (const { old_string: from, new_string: to, replace_all: all } of edits ?? []) {
    if (!text.includes(from)) return null;
    text = all ? text.split(from).join(to) : text.replace(from, () => to);
  }
  return text;
}
