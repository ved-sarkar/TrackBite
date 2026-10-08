# TrackWeight source reference

This folder contains the existing weighing application's source, included as an attributed foundation for TrackBite. It is **third-party TrackWeight code**, separate from the new manual nutrition app at the repository root. It is not evidence of connected camera or trackpad features in that app.

## Provenance

- Upstream: [KrishKrosh/TrackWeight](https://github.com/KrishKrosh/TrackWeight/tree/0ce094c51525335cbf6948a2abc0352cfe066d91).
- Snapshot commit: `0ce094c51525335cbf6948a2abc0352cfe066d91`.
- All 13 Swift files, including `Package.swift`, match that commit byte-for-byte.
- TrackWeight license: [MIT, copyright 2025 Krish Shah](LICENSE).
- OpenMultitouchSupport: Takuto Nakamura (Kyome22), with its [MIT notice](LICENSE-OpenMultitouchSupport) obtained from the `3.0.3` tag. Existing author headers remain intact.

The original upstream documentation is preserved as [UPSTREAM_README.md](UPSTREAM_README.md). Its demonstrations, measurement claims, and installation guidance are upstream statements, not independent TrackBite validation.

## Included source

| Path | Existing role |
| --- | --- |
| `TrackWeight/` | SwiftUI app, scale/debug/guided-weighing views and view models, original app icons, and empty entitlements file |
| `Sources/OpenMultitouchSupport/` | Existing Swift wrappers for multitouch events |
| `Package.swift` | Library package referencing the upstream 3.0.3 binary framework and checksum |
| `TrackWeight.xcodeproj/` | Upstream Xcode project with development-team/signing-identity assignments removed |

The source describes pressure-based weighing on a compatible Mac trackpad. The package is a support library; it is not a standalone `swift run TrackBite` executable. The Xcode app still identifies itself as TrackWeight. No rebranding or new application feature was added.

## Preparation boundaries

The Xcode project starts from the upstream committed version, not the local signing modifications. Development-team, signing-identity and provisioning-profile assignments were stripped where present. Export/signing options, user/workspace state, Git history, release automation, caches and build outputs are excluded. Source files and original icon assets were preserved; compiled frameworks are not bundled.

No build, application launch, hardware access, dependency download, measurement test, or nutrition test was performed for this source addition. To explore the original application, consult the upstream documentation and review its hardware, toolchain, framework and signing requirements for your own machine. The root TrackBite app implements manual nutrition entry and a local meal log separately; this source reference does not connect its weighing functionality to that app.
