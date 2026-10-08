import SwiftUI
import NutritionCore

struct ScaleDemoView: View {
    @Environment(\.openWindow) private var openWindow
    @State private var scenario: DemoScenario = .emptyPlate
    @State private var candidate: FoodCandidate?
    @State private var demoEntry: Ingredient?
    private let ink = TrackBiteTheme.navy
    private let accent = TrackBiteTheme.lightCopper
    private let paper = TrackBiteTheme.ivory
    private let scale = MockScaleAdapter()
    private let identifier = MockFoodIdentificationAdapter()
    private var reading: ScaleReading { (try? scale.snapshot(for: scenario)) ?? scenario.reading }
    private var food: Bool { scenario == .plateAndFood }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Label("TrackBite", systemImage: "scalemass").font(.system(size: 28, weight: .bold))
                Spacer()
                Text("DEMO · SIMULATED READINGS").font(.system(size: 11, weight: .medium)).tracking(1)
                    .padding(10).overlay(Capsule().stroke(ink.opacity(0.2)))
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("Every portion has a story.").font(.system(size: 38, weight: .regular, design: .serif))
                Text("Start with its weight. Add context. Keep what matters.").foregroundStyle(ink.opacity(0.65))
            }
            HStack(alignment: .top, spacing: 22) {
                VStack(spacing: 22) {
                    HStack {
                        Text("FORCE TOUCH · CONCEPT DEMO").font(.system(size: 11)).tracking(1.5)
                        Spacer()
                        Text(food ? "02 / PLATE + FOOD" : "01 / EMPTY PLATE").font(.system(size: 11)).foregroundStyle(accent)
                    }
                    Spacer(minLength: 8)
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text((food ? reading.net : reading.gross).formatted(.number.precision(.fractionLength(0))))
                            .font(.system(size: 152, weight: .regular, design: .rounded)).monospacedDigit()
                        Text("g").font(.system(size: 40)).foregroundStyle(accent)
                    }.accessibilityElement(children: .combine)
                    Text(food ? "Net food · plate tared" : "Empty plate · total weight").foregroundStyle(accent)
                    Spacer(minLength: 8)
                    Divider().overlay(Color.white.opacity(0.2))
                    HStack {
                        metric("GROSS / TOTAL", reading.gross)
                        Spacer()
                        metric("PLATE / TARE", reading.tare)
                        Spacer()
                        metric("NET FOOD", reading.net)
                    }
                }.padding(30).frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(ink).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 17))
                VStack(alignment: .leading, spacing: 17) {
                    Text("02 / THE NEXT INGREDIENT").font(.system(size: 11)).tracking(1.5)
                    VStack(spacing: 8) {
                        Image(systemName: "camera").font(.system(size: 32, weight: .light))
                        Text("CAMERA OFF").font(.system(size: 9)).tracking(2)
                    }.frame(maxWidth: .infinity).padding(18).background(paper).clipShape(RoundedRectangle(cornerRadius: 15))
                    Text(food ? "Now, the food." : "First, the plate.").font(.system(size: 24, weight: .semibold))
                    Text(food ? "140 g total, minus the 100 g plate. Preview an example food match for this 40 g portion." : "The demo remembers a 100 g plate as the tare. Select the food state to reveal the net portion.")
                        .font(.system(size: 13)).fixedSize(horizontal: false, vertical: true)
                    Button("Preview food identification") { candidate = try? identifier.previewCandidate() }
                        .buttonStyle(.borderedProminent).tint(TrackBiteTheme.copper).disabled(!food)
                    if let candidate {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(candidate.name) · 40 g").font(.headline)
                            Text("Mock match · Sample 50 kcal / 100 g").font(.caption)
                            Text("Portion estimate: 20 kcal").font(.callout)
                        }
                        Button("Confirm & log demo portion") {
                            demoEntry = try? candidate.ingredient(reading: reading, confirmed: true)
                        }.disabled(demoEntry != nil)
                    }
                    if demoEntry != nil { Text("Logged for this session · 40 g · 20 kcal").font(.caption) }
                    Spacer(minLength: 0)
                    Text("Mock identification & illustrative nutrition.\nNo camera, sensor, or network access.")
                        .font(.system(size: 11)).foregroundStyle(ink.opacity(0.65))
                }.padding(24).frame(width: 290, alignment: .leading).frame(maxHeight: .infinity)
                    .background(TrackBiteTheme.paper).clipShape(RoundedRectangle(cornerRadius: 17))
            }
            HStack {
                Button("① Empty plate · 100 g") { select(.emptyPlate) }.keyboardShortcut("1", modifiers: [])
                    .buttonStyle(.borderedProminent).tint(food ? ink.opacity(0.5) : ink)
                Button("② Plate + food · 140 g") { select(.plateAndFood) }.keyboardShortcut("2", modifiers: [])
                    .buttonStyle(.borderedProminent).tint(food ? ink : ink.opacity(0.5))
                Spacer()
                Button("Ingredients & meal log") { openWindow(id: "manual-log") }
                Button("Full screen") { NSApp.keyWindow?.toggleFullScreen(nil) }
            }
            HStack {
                Text("100 g plate + 40 g food = 140 g gross")
                Spacer()
                Text("Keys 1 / 2 switch states · Demo entries clear on close")
            }.font(.system(size: 11)).foregroundStyle(ink.opacity(0.65))
        }.padding(32).background(paper).foregroundStyle(ink)
            .frame(minWidth: 1000, minHeight: 720).preferredColorScheme(.light)
    }
    private func select(_ next: DemoScenario) { scenario = next; candidate = nil; demoEntry = nil }
    private func metric(_ title: String, _ value: Double) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.system(size: 10)).foregroundStyle(.white.opacity(0.7))
            Text("\(value.formatted(.number.precision(.fractionLength(0)))) g").font(.system(size: 24))
        }
    }
}
