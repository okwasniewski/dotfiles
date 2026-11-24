# iOS, Android and React Native toolchain. Xcode itself comes from Xcodes.app,
# the Android SDK from Android Studio.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cmake
    ninja
    scrcpy
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
      "swiftlint"
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
