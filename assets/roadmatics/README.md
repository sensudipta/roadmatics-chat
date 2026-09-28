<!-- SPDX-FileCopyrightText: 2026 Roadmatics Technologies -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# Roadmatics Chat logo files

The user supplied the blue/cyan cube-and-chat brand poster on 2026-09-29 and
requested it as the app logo. The full-colour master was generated from that
reference with image editing: the central mark is isolated on transparency,
without poster text, scenery, glow beams or the duplicate icon. It is a raster
adaptation, not a pixel-exact extraction or a vector reconstruction.

| File | Purpose |
| --- | --- |
| `logo_master.png` | 1254 × 1254 transparent source master |
| `logo.png` | 1024 × 1024 transparent logo for in-app and splash use; Android adaptive foreground |
| `app_icon.png` | 1024 × 1024 opaque icon on pale blue `#F4FCFF`; iOS and legacy Android source |
| `logo_monochrome.svg` | Simplified white cube/chat vector for Android notification and themed icons |
| `logo_monochrome.png` | 1024 × 1024 transparent raster of the monochrome vector |

The monochrome variant intentionally uses simpler geometry so system tinting
and small notification sizes preserve recognizable details. It is not the
full-colour 3D artwork converted to SVG. Platform launchers apply their own icon
masks; the opaque master does not contain a pre-rounded tile. The adaptive
foreground uses the generator's 18% inset for mask-safe padding.

Regenerate all platform sizes from the committed masters:

```bash
bash scripts/generate-roadmatics-icons.sh
```

This requires ImageMagick and the project's Dart/Flutter environment. Outputs
are in Android `res/{mipmap,drawable}-*` and iOS `Assets.xcassets`. The iOS icons
are prepared assets; this Linux workflow does not validate an iOS build.

The older `rc*` files are retained as the superseded placeholder artwork and
are no longer referenced by the app or the icon generator.
