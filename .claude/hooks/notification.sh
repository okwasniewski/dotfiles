#!/bin/bash

is_terminal_focused() {
  local focused_app
  focused_app=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)
  [[ "$focused_app" == "ghostty" ]]
}

is_tmux_session_active() {
  [[ -z "$TMUX" ]] && return 0

  local current_session="${TMUX##*,}"
  [[ -z "$current_session" ]] && return 0

  local attached_session
  attached_session=$(tmux list-sessions -F '#{session_attached} #{session_id}' 2>/dev/null | grep '^1' | cut -d' ' -f2)
  [[ "$attached_session" == "\$$current_session" ]]
}

get_tmux_session_name() {
  [[ -z "$TMUX_PANE" ]] && echo "Unknown" && return

  local session_name
  session_name=$(tmux display-message -t "$TMUX_PANE" -p '#{session_name}' 2>/dev/null)
  echo "${session_name:-Unknown}"
}

if ! is_terminal_focused || ! is_tmux_session_active; then
  session_name=$(get_tmux_session_name)
  osascript -e "display notification \"Ready for your input in $session_name\" with title \"Claude Code - $session_name\" sound name \"Pop\""
fi
