import type { Plugin } from "@opencode-ai/plugin";

export const NotificationPlugin: Plugin = async ({ $ }) => {
  const isTerminalFocused = async (): Promise<boolean> => {
    const result =
      await $`osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true'`.text();
    return result.trim() === "ghostty";
  };

  /**
   * Checks if current tmux session is the attached one
   */
  const isTmuxSessionActive = async (): Promise<boolean> => {
    const tmuxEnv = process.env.TMUX;
    if (!tmuxEnv) return true;

    const currentSession = tmuxEnv.split(",")[2];
    if (!currentSession) return true;

    try {
      const attachedSession =
        await $`tmux list-sessions -F '#{session_attached} #{session_id}' | grep '^1' | cut -d' ' -f2`.text();
      return attachedSession.trim() === `$${currentSession}`;
    } catch {
      return true;
    }
  };

  /**
   * Gets tmux session name for current pane
   */
  const getTmuxSessionName = async (): Promise<string> => {
    const currentPane = process.env.TMUX_PANE;
    if (!currentPane) return "Unknown";

    try {
      const sessionName =
        await $`tmux display-message -t ${currentPane} -p '#{session_name}'`.text();
      return sessionName.trim() || "Unknown";
    } catch {
      return "Unknown";
    }
  };

  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        const terminalFocused = await isTerminalFocused();
        const sessionActive = await isTmuxSessionActive();

        if (!terminalFocused || !sessionActive) {
          const sessionName = await getTmuxSessionName();
          await $`osascript -e 'display notification "Ready for your input in ${sessionName}" with title "OpenCode - ${sessionName}" sound name "Pop"'`;
        }
      }
    },
  };
};
