# Implementation and validation

## Calculation contract

Each ingredient stores a name, a positive weight in grams, and entered per-100-g values for energy (kcal), protein, carbohydrate and fat (grams). Its contribution is `weight / 100 × value`. A meal sums ingredient contributions. Energy is the entered energy value scaled by weight; the app does not reconstruct energy from a 4/4/9 formula or infer missing nutrient values.

Names cannot be blank; weights must be finite and positive; nutrients must be finite and nonnegative. Empty meals, duplicate stored identifiers, overflowed totals, and malformed saved data are rejected. These checks validate numeric structure, not the accuracy or biological plausibility of a nutrition label.

## Persistence contract

Saved meals retain their ingredient inputs and stable identifiers. Totals are calculated from those saved inputs when reviewed. A write is committed to memory only after the complete JSON file is saved atomically. A failed save leaves the draft available to retry. A malformed existing log is not silently replaced with an empty one. Storage is a local plaintext file without multi-process locking or cloud synchronization.

## Focused verification

Checked on 2026-10-08 using Apple Swift 6.3.2 on Apple Silicon:

- `swift run NutritionChecks`: all six check groups passed, covering per-100-g scaling and mixed meals, invalid inputs, overflow/duplicate ingredients, save/reload/delete, malformed/duplicate logs, and failed writes.
- `swift build --product TrackBite`: the SwiftUI application compiled and linked successfully.

The checks use fictional arithmetic inputs and temporary files. They do not access personal meal logs, photos, hardware, provider APIs, or a food database. The app was compiled but not launched; UI interaction and physical weighing remain unverified. No accuracy claim follows from passing arithmetic checks.

The root app is separate from the preserved third-party weighing project. Compiling the root package does not establish that the original Xcode weighing project builds, calibrates accurately, or works with any particular trackpad. Camera recognition and direct hardware integration are not part of this implementation.
