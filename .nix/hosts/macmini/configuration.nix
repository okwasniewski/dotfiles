{ ... }:

{
  power.sleep.computer = "never";
  power.sleep.display = 10;
  power.sleep.harddisk = "never";
  power.restartAfterPowerFailure = true;
  power.restartAfterFreeze = true;

  services.openssh.enable = true;

  # Keeps agents running across reboots, see WORKFLOW.md "Remote dev on the mac mini".
  # Started through a login shell so launchd agents pick up PATH from ~/.zprofile.
  launchd.user.agents.herdr-server.serviceConfig = {
    Label = "dev.herdr.server";
    ProgramArguments = [
      "/bin/zsh"
      "-lc"
      "exec herdr server"
    ];
    RunAtLoad = true;
    KeepAlive = true;
    ProcessType = "Interactive";
    StandardOutPath = "/tmp/herdr-server.out.log";
    StandardErrorPath = "/tmp/herdr-server.err.log";
  };

  launchd.user.agents.dotfiles-pull.serviceConfig = {
    Label = "dev.oskar.dotfiles-pull";
    ProgramArguments = [
      "/bin/zsh"
      "-lc"
      "git -C \"$HOME/dotfiles\" pull --ff-only"
    ];
    StartCalendarInterval = [
      {
        Hour = 9;
        Minute = 0;
      }
    ];
    RunAtLoad = true;
    StandardOutPath = "/tmp/dotfiles-pull.log";
    StandardErrorPath = "/tmp/dotfiles-pull.log";
  };

  system.activationScripts.postActivation.text = ''
    pmset -a womp 1
    launchctl enable system/com.apple.screensharing
    launchctl bootstrap system /System/Library/LaunchDaemons/com.apple.screensharing.plist 2>/dev/null || true
  '';
}
