{ ... }:

{
  power.sleep.computer = "never";
  power.sleep.display = 10;
  power.sleep.harddisk = "never";
  power.restartAfterPowerFailure = true;
  power.restartAfterFreeze = true;

  services.openssh.enable = true;

  # Started through a login shell so the agent picks up PATH from ~/.zprofile.
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
