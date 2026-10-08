# Prototype validation

## Passed

- Native SwiftUI build on arm64 macOS with Apple Swift 6.3.2.
- Seven native check groups covering gross/tare/net, rejected invalid readings, explicit candidate confirmation, nutrient scaling, persistence, malformed logs and failed writes.
- Offline demo script checks covering both weighing states, ingredient review, required naming, confirmed logging, navigation, reset and keyboard shortcuts. Shortcuts do not consume typing inside the ingredient-name field.
- Vendored TrackWeight source and MIT notices preserved byte-for-byte. The nutrition and storage implementations remain unchanged.

- Both user-supplied demonstration photos were visually reviewed and published in the README. Their simulated-reading labels remain visible, no sensitive background information was identified, and the JPEGs contain no EXIF, location data or embedded comments. The published images match the originals byte-for-byte; they illustrate the concept demo, not validated hardware measurements.

The browser checks use a small DOM stub to exercise state and event behavior. They do not certify visual layout or accessibility in a real browser. The native package has no external dependencies; no private framework, camera, model or paid service was activated.

## Outstanding

- Automated browser rendering was blocked by the local-file URL security policy; no workaround was attempted. The redesigned interface has not been visually verified in this environment. Native screens compiled but were not launched for a capture. No screenshots are claimed or included.
- No physical weighing, safe load limit, device-specific calibration or food-recognition accuracy has been validated. The 100/140/40 g demonstration is simulated.

## Reproduce

```sh
swift build
swift run NutritionChecks
node scripts/check-demo.cjs
```

The offline demo can be opened directly in a browser for manual visual review. Both state buttons, all three navigation screens, confirmation, reset and full-screen controls should be checked. Keep the Demo badge visible in any future captures; staged photographs must be captioned as simulated concept demonstrations.
