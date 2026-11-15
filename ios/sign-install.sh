#!/bin/bash
# Sign the iOS build with Markus's paid dev team (wildcard profile) and install it on a device.
#   ios/sign-install.sh [UDID]     (default: his iPhone 15 Pro Max)
set -euo pipefail
cd "$(dirname "$0")/.."
UDID=${1:-00008130-001A68443C2B803A}
APP=build/ios/defjam_recomp.app
TEAM=MNU46BX5M3
BID=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' $APP/Info.plist)
PROFILE=${DEFJAM_IOS_PROFILE:-"$HOME/Library/Developer/Xcode/UserData/Provisioning Profiles/5ce2f268-ed9b-4e3e-a6d8-e0b3f6a6e1c4.mobileprovision"}
[ -f "$PROFILE" ] || PROFILE=$(ls "$HOME/Library/Developer/Xcode/UserData/Provisioning Profiles/"5ce2f268*.mobileprovision | head -1)
IDENT=${DEFJAM_IOS_IDENTITY:-"Apple Development: Markus Useche (X6B36PP3R6)"}
cp "$PROFILE" $APP/embedded.mobileprovision
ENT=build/ios/entitlements.plist
cat > $ENT <<PL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>application-identifier</key><string>$TEAM.$BID</string>
<key>com.apple.developer.team-identifier</key><string>$TEAM</string>
<key>get-task-allow</key><true/>
<key>keychain-access-groups</key><array><string>$TEAM.$BID</string></array>
</dict></plist>
PL
codesign --force --sign "$IDENT" --entitlements $ENT --timestamp=none $APP
codesign -dv $APP 2>&1 | grep -E "Identifier|TeamIdentifier"
xcrun devicectl device install app --device "$UDID" $APP
