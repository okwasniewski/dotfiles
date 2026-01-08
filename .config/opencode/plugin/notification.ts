import type { Plugin } from "@opencode-ai/plugin";

export const NotificationPlugin: Plugin = async ({
  project,
  client,
  $,
  directory,
  worktree,
}) => {
  const isTerminalFocused = async (): Promise<boolean> => {
    const result =
      await $`osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true'`.text();
    return result.trim() === "ghostty";
  };

  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        const kittyFocused = await isTerminalFocused();
        if (!kittyFocused) {
          // MacOS sounds can be found on /System/Library/Sounds
          await $`osascript -e 'display notification "Ready for your input!" with title "OpenCode" sound name "Pop"'`;
        }
      }
    },
  };
};
