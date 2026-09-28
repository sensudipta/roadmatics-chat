#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Roadmatics Technologies
# SPDX-License-Identifier: AGPL-3.0-or-later
set -euo pipefail
cd "$(dirname "$0")/.."
magick assets/roadmatics/logo_master.png -resize 1024x1024 assets/roadmatics/logo.png
magick assets/roadmatics/logo.png -background '#F4FCFF' -alpha remove -alpha off assets/roadmatics/app_icon.png
magick -background none assets/roadmatics/logo_monochrome.svg assets/roadmatics/logo_monochrome.png
dart run flutter_launcher_icons
for density in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
  case "$density" in
    mdpi) size=128; glyph=24;;
    hdpi) size=192; glyph=36;;
    xhdpi) size=256; glyph=48;;
    xxhdpi) size=384; glyph=72;;
    xxxhdpi) size=512; glyph=96;;
  esac
  magick assets/roadmatics/logo.png -resize "${size}x${size}" "android/app/src/main/res/drawable-$density/splash.png"
  magick assets/roadmatics/logo_monochrome.png -resize "${glyph}x${glyph}" "android/app/src/main/res/drawable-$density/notifications_icon.png"
done
for scale in 1 2 3; do
  suffix="@$scale"x
  if [ "$scale" = 1 ]; then suffix=''; fi
  size=$((128 * scale))
  magick assets/roadmatics/logo.png -resize "${size}x${size}" "ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage${suffix}.png"
done
