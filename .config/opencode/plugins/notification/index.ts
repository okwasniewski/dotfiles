import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { Plugin } from "@opencode/plugin";

const run = async (command: string, args: string[]) => (await promisify(execFile)(command, args)).stdout.trim();

const isTerminalFocused = async () =>
  (await run("osascript", [
    "-e",
    'tell application "System Events" to get name of first application process whose frontmost is true',
  ])) === "ghostty";

const isTmuxSessionActive = async () => {
  const currentSession = process.env.TMUX?.split(",")[2];
  if (!currentSession) return true;
  try {
    const sessions = await run("tmux", ["list-sessions", "-F", "#{session_attached} #{session_id}"]);
    const attached = sessions.split("\n").find((line) => line.startsWith("1 "))?.split(" ")[1];
    return attached === `$${currentSession}`;
  } catch {
    return true;
  }
};

const tmuxSessionName = async () => {
  const pane = process.env.TMUX_PANE;
  if (!pane) return "Unknown";
  try {
    return (await run("tmux", ["display-message", "-t", pane, "-p", "#{session_name}"])) || "Unknown";
  } catch {
    return "Unknown";
  }
};

export default Plugin.define({
  id: "notification",
  setup(ctx) {
    const controller = new AbortController();

    void (async () => {
      for await (const event of ctx.event.subscribe({ types: ["session.idle"], signal: controller.signal })) {
        if (event.type !== "session.idle") continue;
        if ((await isTerminalFocused()) && (await isTmuxSessionActive())) continue;
        const name = await tmuxSessionName();
        await run("osascript", [
          "-e",
          `display notification "Ready for your input in ${name}" with title "OpenCode - ${name}" sound name "Pop"`,
        ]);
      }
    })();

    return () => controller.abort();
  },
});
