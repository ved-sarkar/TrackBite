# TrackBite

**Weigh a portion. Understand the food. Keep the context.**

TrackBite explores a MacBook Force Touch trackpad as the weighing foundation for a camera-assisted nutrition workflow. The intended experience starts at the scale: subtract the plate, identify the food, confirm its nutrition source, then log the portion.

## Why I built this

TrackBite started with a student-life problem: I cared about nutrition and going to the gym, but had a limited budget and little equipment. I wondered whether my laptop’s trackpad could work like a weighing scale. That question later grew into the idea of using a camera to log food and track macros.

![TrackBite concept diagram showing 140 g gross minus 100 g tare equals 40 g food, followed by food identification and logging.](docs/images/workflow.svg)

*Concept diagram, not an app screenshot. The current prototype uses simulated weights and a mock food match; live trackpad capture and camera recognition are future integrations.*

## Try the portion studio

Download or clone the repository, then open **[demo/TrackBite-Demo.html](demo/TrackBite-Demo.html)** in Safari or Chrome. The file is a complete offline interface—no server, installation, account or API key needed. GitHub's file viewer shows its source; open the downloaded file in your browser to use it.

The navy, ivory and copper studio connects three screens:

| Screen | What you can do now |
| --- | --- |
| **01 / Weigh** | Switch between the empty plate and food states; view gross, tare and net together. |
| **02 / Ingredient** | Review a labeled mock food match, edit its name, and confirm the portion. |
| **03 / Meal log** | Inspect the confirmed demo entry and its calculation; reset for another demonstration. |

- **Press 1:** empty plate **100 g total**, tare **100 g**, food **0 g**.
- **Press 2:** plate + food **140 g gross**, tare **100 g**, food **40 g net**.
- **Press F:** full screen. **Esc:** exit. The Demo badge stays visible throughout.

The portion example uses fictional values of 50 kcal per 100 g, so 40 g produces 20 kcal. Demo entries stay in memory and clear when the scale state changes or the page closes. The interface makes no sensor, camera or network calls. No physical loading is needed to operate the demonstration.

## Native Mac app

With macOS 13+ and a Swift 5.9-compatible developer toolchain:

```sh
swift run TrackBite
```

The app opens to the scale demo. Select **Ingredients & meal log** to open the native manual workflow, styled in the same palette. Enter a meal name, add ingredients with their weights and nutrition values per 100 g, review the totals, and save locally. The ingredient editor supports corrections; meal deletion asks for confirmation.

Demo entries are separate from saved manual meals. The manual log retains its existing storage at `~/Library/Application Support/TrackBite/meals.json`, with atomic saves and validation that preserves malformed files instead of overwriting them. The JSON file is not encrypted; unsaved drafts clear on close. There is no cloud sync or coordination between separate app processes.

## Implemented today, envisioned next

| Implemented prototype | Envisioned integration |
| --- | --- |
| Two explicit simulated scale states and net-weight arithmetic | Fresh readings from a reviewed native Force Touch adapter |
| Local mock candidate with confirmation | User-initiated camera capture or photo import, candidate matches and corrections |
| Sample nutrition scaling; manual ingredient values | An attributed food-composition source with cooked/raw and preparation context |
| Session demo log; persistent native manual log | A saved entry that retains measurement and food-source provenance |

A photo plus total mass does not reveal a mixed dish's ingredient composition. The proposed workflow keeps food identification and nutrition-source confirmation in the user's hands.

## Hardware foundation

The attributed [TrackWeight source](third_party/trackweight/README.md) is included as an integration reference, separately from the root app. It describes Force Touch hardware, capacitive-contact dependence and private multitouch access. This repository has not established a safe trackpad load limit, device-specific calibration or accuracy tolerance. The displayed demo numbers are fixtures, not validated hardware readings. See [integration notes](docs/CONCEPT-INTEGRATION.txt) for source findings and the remaining permission/provider decisions.

## Build and checks

```sh
swift build
swift run NutritionChecks
node scripts/check-demo.cjs
```

The root Swift package has no external dependencies and does not build or download the vendored framework. Checks cover nutrition, persistence, invalid inputs, gross/tare/net, confirmation and demo navigation. See [validation](docs/VALIDATION.md) for the distinction between successful build/calculation checks and the outstanding visual/hardware review.

## Credits

TrackBite's interface, nutrition workflow, mock adapters and documentation were developed with AI assistance. The weighing foundation is **TrackWeight by Krish Shah**, using **OpenMultitouchSupport by Takuto Nakamura**. Vendored source and both MIT notices are preserved unchanged. See [attribution and license status](ATTRIBUTION.md); the third-party MIT terms do not relicense original TrackBite material.
