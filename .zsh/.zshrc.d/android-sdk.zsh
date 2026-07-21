if [ -d "/Applications/Android Studio.app" ]; then
  export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
  export PATH="$JAVA_HOME/bin:$PATH"
fi

if [ -x "$HOME/Library/Android/sdk/platform-tools/adb" ]; then
  alias adb="$HOME/Library/Android/sdk/platform-tools/adb"
fi
if [ -x "$HOME/Library/Android/sdk/tools/emulator" ]; then
  alias android-emulator-list="$HOME/Library/Android/sdk/tools/emulator -list-avds"
  alias android-emulator-run="$HOME/Library/Android/sdk/tools/emulator -avd"
fi

