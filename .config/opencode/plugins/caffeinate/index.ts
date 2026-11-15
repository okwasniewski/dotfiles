import { type ChildProcess, spawn } from "node:child_process";
import { Plugin } from "@opencode/plugin";

// Credits go to @elithrar
// https://github.com/elithrar/dotfiles/blob/main/.config/opencode/plugin/caffeinate.ts
export default Plugin.define({
  id: "caffeinate",
  setup(ctx) {
    if (process.platform !== "darwin") return;

    const busySessions = new Set<string>();
    const controller = new AbortController();
    let caffeinate: ChildProcess | null = null;

    void (async () => {
      for await (const event of ctx.event.subscribe({ types: ["session.status"], signal: controller.signal })) {
        if (event.type !== "session.status") continue;
        const { sessionID, status } = event.data;
        if (status.type === "idle") busySessions.delete(sessionID);
        else busySessions.add(sessionID);

        if (busySessions.size > 0 && !caffeinate) {
          caffeinate = spawn("caffeinate", ["-i"], { stdio: "ignore" });
        } else if (busySessions.size === 0 && caffeinate) {
          caffeinate.kill();
          caffeinate = null;
        }
      }
    })();

    return () => {
      controller.abort();
      caffeinate?.kill();
    };
  },
});
