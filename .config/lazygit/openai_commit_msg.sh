#!/usr/bin/env bash

set -euo pipefail

if ! command -v git >/dev/null 2>&1; then
  echo "Error: git is required." >&2
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is required." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required." >&2
  exit 1
fi

if [ -z "${OPENAI_API_KEY:-}" ]; then
  echo "Error: OPENAI_API_KEY is not set." >&2
  exit 1
fi

BRANCH_NAME=$(git symbolic-ref --short HEAD 2>/dev/null || true)
if [ -z "$BRANCH_NAME" ]; then
  echo "Error: Not in a git repository or detached HEAD." >&2
  exit 1
fi

FILES=$(git diff --cached --name-only)
if [ -z "$FILES" ]; then
  echo "Error: No staged changes found." >&2
  exit 1
fi

DIFF=$(git diff --cached --diff-algorithm=minimal --no-ext-diff)
STATS=$(git diff --cached --stat --no-ext-diff)
MAX_DIFF_CHARS=${OPENAI_COMMIT_MAX_DIFF_CHARS:-40000}

if [ "${#DIFF}" -gt "$MAX_DIFF_CHARS" ]; then
  DIFF="${DIFF:0:$MAX_DIFF_CHARS}

[diff truncated]"
fi

MODEL=${OPENAI_MODEL:-gpt-5.4-mini}
API_BASE=${OPENAI_API_BASE:-https://api.openai.com/v1}

PROMPT=$(cat <<EOF
Write a single git commit subject for the staged changes.

Rules:
- Use Conventional Commits format: <type>: <description>
- Types allowed: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
- Output only the commit subject line
- No quotes, no markdown, no explanation
- Keep it concise, ideally under 72 chars
- Prefer the most meaningful user-facing change

Branch:
$BRANCH_NAME

Files:
$FILES

Diff stat:
$STATS

Diff:
$DIFF
EOF
)

PAYLOAD=$(jq -n \
  --arg model "$MODEL" \
  --arg prompt "$PROMPT" \
  '{
    model: $model,
    temperature: 0.2,
    messages: [
      {
        role: "system",
        content: "You write excellent git commit messages."
      },
      {
        role: "user",
        content: $prompt
      }
    ]
  }')

RESPONSE=$(curl -fsSL "$API_BASE/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d "$PAYLOAD")

COMMIT_MSG=$(echo "$RESPONSE" | jq -r '.choices[0].message.content // empty' | tr '\n' ' ' | sed -E 's/^\s+|\s+$//g; s/^"|"$//g; s/[[:space:]]+/ /g')

if [ -z "$COMMIT_MSG" ] || [ "$COMMIT_MSG" = "null" ]; then
  echo "Error: Failed to generate commit message." >&2
  echo "$RESPONSE" >&2
  exit 1
fi

echo "$COMMIT_MSG"
