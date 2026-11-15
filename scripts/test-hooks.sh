#!/usr/bin/env bash
# Exercises the global git hooks and the Claude Code guard hooks in a scratch repo.
set -uo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
git_hooks="$root/.config/git/hooks"
claude_hooks="$root/.claude/hooks"
em=$'\xe2\x80\x94'
failures=0

check() {
  local want=$1 name=$2
  shift 2
  "$@" >/dev/null 2>&1
  local got=$?
  if { [ "$want" = pass ] && [ $got -eq 0 ]; } || { [ "$want" = fail ] && [ $got -ne 0 ]; }; then
    printf 'ok    %s\n' "$name"
  else
    printf 'FAIL  %s (exit %s)\n' "$name" "$got"
    failures=$((failures + 1))
  fi
}

msg() { printf '%s\n' "$1" >"$tmp/msg" && "$git_hooks/commit-msg" "$tmp/msg"; }
push() { printf 'refs/heads/x %s refs/heads/%s 0000000000000000000000000000000000000000\n' "$(git rev-parse HEAD)" "$1" | "$git_hooks/pre-push" origin url; }
claude() { printf '%s' "$2" | "$claude_hooks/$1"; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cd "$tmp" || exit 1
git init -q -b main repo && cd repo || exit 1
git config user.email t@t && git config user.name t && git config commit.gpgsign false
git commit -q --allow-empty -m init

echo '== commit-msg'
check pass 'conventional subject' msg 'feat(git): add hooks'
check pass 'breaking change' msg 'fix!: drop node 18'
check pass 'merge commit' msg "Merge branch 'x'"
check pass 'fixup commit' msg 'fixup! feat: x'
check fail 'no type' msg 'add hooks'
check fail 'unknown type' msg 'feature: add hooks'
check fail 'subject over 72 chars' msg "feat: $(printf 'a%.0s' {1..70})"
check fail 'em dash in body' msg "$(printf 'feat: x\n\nwhy %s because' "$em")"
check pass 'comment lines ignored' msg "$(printf 'feat: x\n# %s comment' "$em")"

echo '== pre-commit'
printf 'plain - hyphen\n' >ok.md && git add ok.md
check pass 'hyphen only' "$git_hooks/pre-commit"
printf 'bad %s dash\n' "$em" >bad.md && git add bad.md
check fail 'em dash added' "$git_hooks/pre-commit"
printf 'bad.md linguist-vendored\n' >.gitattributes
check pass 'vendored file skipped' "$git_hooks/pre-commit"
git commit -q --no-verify -m 'chore: seed'
printf 'bad %s dash\nnew line\n' "$em" >bad.md && printf '' >.gitattributes && git add -A
check pass 'existing dash untouched' "$git_hooks/pre-commit"

echo '== pre-push'
check pass 'oskar/ branch' push oskar/feature
check pass 'main' push main
check fail 'unprefixed branch' push feature
check pass 'branch delete' bash -c "printf '(delete) 0000000000000000000000000000000000000000 refs/heads/x abc\n' | '$git_hooks/pre-push' origin url"

echo '== claude package-manager'
mkdir -p pnpm-app/sub && touch pnpm-app/pnpm-lock.yaml
check fail 'npm install in pnpm project' claude package-manager.mjs "{\"cwd\":\"$PWD/pnpm-app\",\"tool_input\":{\"command\":\"npm install\"}}"
check fail 'nested dir, env prefix' claude package-manager.mjs "{\"cwd\":\"$PWD/pnpm-app/sub\",\"tool_input\":{\"command\":\"CI=1 yarn add x\"}}"
check fail 'cd then npm run' claude package-manager.mjs "{\"cwd\":\"$PWD\",\"tool_input\":{\"command\":\"cd pnpm-app && npm run build\"}}"
check pass 'pnpm install' claude package-manager.mjs "{\"cwd\":\"$PWD/pnpm-app\",\"tool_input\":{\"command\":\"pnpm install\"}}"
check pass 'npm view' claude package-manager.mjs "{\"cwd\":\"$PWD/pnpm-app\",\"tool_input\":{\"command\":\"npm view react version\"}}"
check pass 'global install' claude package-manager.mjs "{\"cwd\":\"$PWD/pnpm-app\",\"tool_input\":{\"command\":\"npm i -g skills\"}}"
check pass 'no lockfile' claude package-manager.mjs "{\"cwd\":\"$PWD\",\"tool_input\":{\"command\":\"npm install\"}}"

echo '== claude file-guards'
seq 1 999 >big.ts
check pass 'stay under 1000 lines' claude file-guards.mjs "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$PWD/big.ts\",\"old_string\":\"999\n\",\"new_string\":\"999\n1000\n\"}}"
check fail 'cross 1000 lines' claude file-guards.mjs "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$PWD/big.ts\",\"old_string\":\"999\n\",\"new_string\":\"999\n1000\n1001\n\"}}"
seq 1 1200 >huge.ts
check pass 'already over 1000' claude file-guards.mjs "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$PWD/huge.ts\",\"old_string\":\"1200\",\"new_string\":\"1200\n1201\"}}"
check fail 'Write adds any' claude file-guards.mjs "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$PWD/a.ts\",\"content\":\"const x = y as any;\n\"}}"
check fail 'MultiEdit adds any' claude file-guards.mjs "{\"tool_name\":\"MultiEdit\",\"tool_input\":{\"file_path\":\"$PWD/big.ts\",\"edits\":[{\"old_string\":\"1\n\",\"new_string\":\"let a: any;\n\"}]}}"
check pass 'any in prose comment' claude file-guards.mjs "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$PWD/a.ts\",\"content\":\"// note: any value works\n\"}}"
check pass 'any in a .md file' claude file-guards.mjs "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$PWD/a.md\",\"content\":\"x: any\n\"}}"

echo
[ $failures -eq 0 ] && echo 'all hook checks passed' || echo "$failures hook check(s) failed"
exit $((failures > 0))
