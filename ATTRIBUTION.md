# Attribution and license status

TrackBite is Ved Sarkar's proposed nutrition workflow. The initial concept document was prepared with AI assistance on 2026-10-07. The manual ingredient-entry app, nutrition calculations, local meal log, focused checks, and updated documentation were newly implemented with AI assistance on 2026-10-08. They are not a historical implementation of the camera/trackpad concept, and no third-party weighing authorship is claimed.

The source reference under [`third_party/trackweight/`](third_party/trackweight/README.md) comes from TrackWeight by Krish Shah at commit `0ce094c51525335cbf6948a2abc0352cfe066d91`. Its [MIT license](third_party/trackweight/LICENSE) retains copyright 2025 Krish Shah. Its trackpad integration uses OpenMultitouchSupport by Takuto Nakamura (Kyome22); the corresponding [MIT notice](third_party/trackweight/LICENSE-OpenMultitouchSupport) and existing source-author headers are preserved.

All 13 upstream Swift files, including the upstream package manifest, are unchanged. Preparation removed signing-team/identity configuration and omitted local workspace state, export settings, automation, and build outputs. The new root application uses a separate Foundation/SwiftUI implementation and does not import the upstream framework or modify its weighing algorithms.

No open-source license is granted for original TrackBite material by this snapshot. Copied third-party source retains its own MIT terms; those notices do not relicense the original TrackBite application or documents. No external food database or nutrition dataset is included. Test inputs are fictional numbers for checking arithmetic, not food-composition claims.

## Scale-first prototype — 2026-10-08

This update adds an offline HTML demo, a native SwiftUI scale view, mock scale/food adapters and focused checks. These additions model the intended trackpad → camera-assisted food match → nutrition log concept with simulated readings; they do not implement or validate live hardware/camera recognition. The prior manual log remains available separately. No copied TrackWeight or OpenMultitouchSupport file was edited. The navy, ivory and copper interface and concept workflow diagram are original additions. The diagram is an illustration, not a captured application screen. User-supplied photographs are excluded until their actual pixels and metadata can be reviewed.
