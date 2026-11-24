# iOS, Android and React Native toolchain. Xcode itself comes from Xcodes.app,
# the Android SDK from Android Studio.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cmake
    ninja
    scrcpy
    # From nix, not Homebrew: the brew formula refuses to install before Xcode.app exists.
    swiftlint
    watchman
    xcbeautify
    yarn
  ];

  homebrew = {
    brews = [
      "ccache"
      "cocoapods"
      "ruby@3.4"
      "swiftformat"
      "xcode-build-server"
    ];
    casks = [
      "android-platform-tools"
      "android-studio"
      "xcodes-app"
      "zulu"
    ];
  };
}
