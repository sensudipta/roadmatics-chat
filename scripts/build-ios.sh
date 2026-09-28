#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2019-Present Christian Kußowski
# SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
#
# SPDX-License-Identifier: AGPL-3.0-or-later

# Firebase support is already enabled in this fork.
set -euo pipefail
flutter pub get --enforce-lockfile
# Retain upstream environment names for callers; Roadmatics bundle IDs are fixed.
if [[ -n "${FLUFFYCHAT_NEW_GROUP:-}" && "${FLUFFYCHAT_NEW_GROUP}" != "com.roadmatics.chat" ]]; then
  echo "Roadmatics bundle ID is com.roadmatics.chat; omit FLUFFYCHAT_NEW_GROUP." >&2
  exit 1
fi
if [[ -n "${FLUFFYCHAT_NEW_TEAM:-}" ]]; then
  if [[ ! "$FLUFFYCHAT_NEW_TEAM" =~ ^[A-Z0-9]{10}$ ]]; then
    echo "FLUFFYCHAT_NEW_TEAM must be a 10-character Apple team ID." >&2
    exit 1
  fi
  sed -i "" -E "s/DEVELOPMENT_TEAM = [^;]*;/DEVELOPMENT_TEAM = $FLUFFYCHAT_NEW_TEAM;/g" ios/Runner.xcodeproj/project.pbxproj
fi
# Configure capabilities/provisioning in Xcode before building; see PUBLICATION_CHECKLIST.md.

### [optional] override pods minimum iphoneos deployment target ###
[ -n "${I_PROMISE_IM_REALLY_SMART:-}" ] && {
# 1. I'm sorry about the indentation't ;_; heredocs are weird about it
# 2. The patch basically just removes any preference on target iOS version
#    This lets our default from ios/Flutter/AppFrameworkInfo.plist take precendence
cat << EOPATCH | patch --forward --reject-file=apple_please_fix_your_coreutils --silent ios/Podfile
diff --git a/ios/Podfile b/ios/Podfile
index 9411102b..0446120a 100644
--- a/ios/Podfile
+++ b/ios/Podfile
@@ -37,5 +37,8 @@ end
 post_install do |installer|
   installer.pods_project.targets.each do |target|
     flutter_additional_ios_build_settings(target)
+    target.build_configurations.each do |config|
+      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
+    end
   end
 end
EOPATCH
rm -f apple_please_fix_your_coreutils
}

### Make release build ###
flutter build ipa --release

### [optional] Install release build ###
[ -n "${FLUFFYCHAT_INSTALL_IPA:-}" ] && {
  ROADMATICS_EXPORT_DIR=$(mktemp -d)
  # 1. Turn the xcarchive that flutter created into a dev-signed IPA
  echo '{"compileBitcode":false,"method":"development"}' | plutil -convert xml1 -o "${ROADMATICS_EXPORT_DIR}/options.plist" -
  xcodebuild -exportArchive -archivePath ./build/ios/archive/Runner.xcarchive -exportPath "${ROADMATICS_EXPORT_DIR}" -exportOptionsPlist "${ROADMATICS_EXPORT_DIR}/options.plist"
  # 2. ...and install it on your connected devices
  shopt -s nullglob
  roadmatics_ipas=("${ROADMATICS_EXPORT_DIR}"/*.ipa)
  if [ "${#roadmatics_ipas[@]}" -ne 1 ]; then
    echo "Expected exactly one exported IPA in $ROADMATICS_EXPORT_DIR" >&2
    exit 1
  fi
  cfgutil --foreach install-app "${roadmatics_ipas[0]}"
  rm -rf "${ROADMATICS_EXPORT_DIR}"
}
