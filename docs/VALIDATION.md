# Prototype validation

## Passed

- Native SwiftUI build on arm64 macOS with Apple Swift 6.3.2.
- Seven nutrition check groups covering gross/tare/net, rejected invalid readings, explicit candidate confirmation, nutrient scaling, persistence, malformed logs and failed writes.
- Offline demo script checks covering all four screens, required meal/ingredient names, invalid nutrition values, recalculation after edits, duplicate-save prevention, preserved session history, escaped names, keyboard shortcuts and offline restrictions.
- Five real SwiftUI captures at 1280×800: empty plate, plate + food, sample identification, ingredient/meal entry and history. Every capture was visually inspected for layout and labeling. The capture harness used byte-identical production views and a synthetic in-memory DemoStudioModel, without opening the persistent manual log. The gallery PNGs were not retouched.
- Both staged demonstration photos are preserved unchanged, including their visible simulated-reading labels. The earlier publication review recorded no sensitive background details and no EXIF/location data or embedded comments.
- Vendored TrackWeight source, source headers and both MIT notices are unchanged. The nutrition and persistence core remains unchanged.

## Scope

The capture harness uses AppKit/NSHostingView to render the actual native SwiftUI components. It does not open a browser page or bypass the earlier browser local-file URL restriction. Browser-script checks use a DOM stub; browser layout and Fullscreen API behavior remain separate manual checks. Native screenshots confirm rendering, not end-to-end device measurement or camera inference.

The 100 g plate / 140 g gross / 40 g net values and sample food nutrients are fixtures. No physical weighing, safe load rating, calibration or food-recognition accuracy is claimed. No private framework, camera, model provider or paid service was activated.

## Reproduce checks

```sh
swift build
swift run NutritionChecks
node scripts/check-demo.cjs
```

In either demo, weigh a portion, review the sample match, confirm it, edit the meal, and save to History. New portions retain earlier entries for the session; closing the demo clears its in-memory history. Native manual meals use the separate persistent log.
