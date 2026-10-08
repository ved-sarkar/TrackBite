import SwiftUI
import NutritionCore

/// The production demo screens. A caller may inject an isolated session for previews.
struct ScaleDemoView: View {
    @Environment(\.openWindow) private var openWindow
    @StateObject var model: DemoStudioModel
    @MainActor init() { _model = StateObject(wrappedValue: DemoStudioModel()) }
    init(model: DemoStudioModel) { _model = StateObject(wrappedValue: model) }
    private let ink = TrackBiteTheme.forest
    private let paper = TrackBiteTheme.paper
    private let cream = TrackBiteTheme.cream
    private let lime = TrackBiteTheme.lime
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack {
                Label("TrackBite", systemImage: "arrow.up.right.square.fill").font(.system(size: 27, weight: .bold))
                Spacer()
                Text("DEMO").font(.system(size: 10, weight: .semibold)).tracking(1)
                    .padding(.horizontal, 13).padding(.vertical, 8)
                    .overlay(Capsule().stroke(ink.opacity(0.18)))
                    .accessibilityLabel("Demo: simulated weight and sample food identification")
            }
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title).font(.system(size: 34, weight: .semibold)).tracking(-1)
                    Text(subtitle).font(.system(size: 14)).foregroundStyle(ink.opacity(0.65))
                }
                Spacer()
                HStack(spacing: 6) {
                    ForEach(StudioScreen.allCases, id: \.self) { page in
                        Button { model.screen = page } label: {
                            Text("\(page.number)  \(page.rawValue)").font(.system(size: 11, weight: .medium))
                                .padding(.horizontal, 11).padding(.vertical, 10)
                                .background(model.screen == page ? ink : Color.clear)
                                .foregroundStyle(model.screen == page ? .white : ink)
                                .clipShape(Capsule())
                        }.buttonStyle(.plain)
                    }
                }
            }
            Group {
                switch model.screen {
                case .weigh: weighing
                case .identify: identification
                case .entry: entry
                case .history: history
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            HStack {
                Text("100 g plate + 40 g food = 140 g gross").font(.system(size: 11)).foregroundStyle(ink.opacity(0.65))
                Spacer()
                Button("Manual meal log") { openWindow(id: "manual-log") }.buttonStyle(.plain)
                Button("Full screen") { NSApp.keyWindow?.toggleFullScreen(nil) }.buttonStyle(.plain)
            }.font(.system(size: 11))
        }.padding(30).background(cream).foregroundStyle(ink)
            .tint(TrackBiteTheme.accent).preferredColorScheme(.light)
            .frame(minWidth: 1080, minHeight: 700)
    }
    private var title: String {
        switch model.screen {
        case .weigh: return "A little weight. A clearer picture."
        case .identify: return "Give your portion a name."
        case .entry: return "Make it part of your meal."
        case .history: return "A little history. A bigger picture."
        }
    }
    private var subtitle: String {
        switch model.screen {
        case .weigh: return "Trackpad weighing meets camera-assisted nutrition."
        case .identify: return "Review the sample match before adding it to a meal."
        case .entry: return "Keep the weight, ingredient and nutrition values together."
        case .history: return "Your saved portions and the values behind each estimate."
        }
    }
    private var weighing: some View {
        VStack(spacing: 16) {
            HStack(spacing: 22) {
                VStack(spacing: 20) {
                    HStack {
                        eyebrow("PORTION WEIGHT").foregroundStyle(.white.opacity(0.7))
                        Spacer()
                        eyebrow(model.hasFood ? "02 / PLATE + FOOD" : "01 / EMPTY PLATE").foregroundStyle(lime)
                    }
                    Spacer()
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text(model.hasFood ? "40" : "100").font(.system(size: 148, weight: .regular)).monospacedDigit().tracking(-8)
                        Text("g").font(.system(size: 35)).foregroundStyle(lime)
                    }
                    Text(model.hasFood ? "Net food · plate tared" : "Empty plate · total weight").font(.system(size: 13)).foregroundStyle(lime)
                    Spacer()
                    Rectangle().fill(.white.opacity(0.2)).frame(height: 1)
                    HStack {
                        scaleMetric("GROSS / TOTAL", model.hasFood ? "140 g" : "100 g")
                        Spacer(); scaleMetric("PLATE / TARE", "100 g")
                        Spacer(); scaleMetric("NET FOOD", model.hasFood ? "40 g" : "0 g")
                    }
                }.padding(30).foregroundStyle(.white).frame(maxWidth: .infinity).background(ink).clipShape(RoundedRectangle(cornerRadius: 24))
                VStack(alignment: .leading, spacing: 21) {
                    eyebrow("FROM PORTION TO PLATE")
                    cameraOff
                    Text(model.hasFood ? "Your portion, in focus." : "Start with the plate.").font(.system(size: 24, weight: .semibold))
                    Text(model.hasFood ? "140 g total, minus the 100 g plate. Bring this 40 g portion into an ingredient review." : "A 100 g plate is set as the tare. Select the food state to reveal the net portion.")
                        .font(.system(size: 13)).lineSpacing(4).foregroundStyle(ink.opacity(0.7))
                    Button("Preview food identification →", action: model.identify).buttonStyle(.borderedProminent).disabled(!model.hasFood)
                    Spacer()
                }.padding(26).frame(width: 300).background(paper).clipShape(RoundedRectangle(cornerRadius: 24))
            }
            HStack {
                Button("① Empty plate · 100 g") { model.select(.emptyPlate) }.keyboardShortcut("1", modifiers: [])
                Button("② Plate + food · 140 g") { model.select(.plateAndFood) }.keyboardShortcut("2", modifiers: [])
                Spacer()
                Text("Keys 1 / 2 switch states").font(.caption).foregroundStyle(ink.opacity(0.6))
            }.buttonStyle(.bordered)
        }
    }
    private var identification: some View {
        Group {
            if model.candidate == nil { emptyPrompt("Start with a portion.", "Choose plate + food, then preview its identification.") }
            else {
                HStack(alignment: .top, spacing: 22) {
                    VStack(alignment: .leading, spacing: 23) {
                        eyebrow("SAMPLE FOOD MATCH")
                        HStack(spacing: 22) {
                            Image(systemName: "fork.knife").font(.system(size: 42, weight: .light)).frame(width: 96, height: 96).background(cream).clipShape(RoundedRectangle(cornerRadius: 20))
                            VStack(alignment: .leading, spacing: 7) {
                                Text("Example food").font(.system(size: 30, weight: .semibold))
                                Text("40 g portion · ready for your review").foregroundStyle(ink.opacity(0.65))
                            }
                        }
                        Divider()
                        eyebrow("ESTIMATED NUTRITION / THIS PORTION")
                        nutrition(Nutrients(energy: 20, protein: 0.8, carbohydrate: 3.2, fat: 0.4))
                        Text("Source: sample values per 100 g").font(.caption).foregroundStyle(ink.opacity(0.65))
                        Spacer()
                        Button("Confirm ingredient →", action: model.confirm).buttonStyle(.borderedProminent)
                    }.card()
                    VStack(alignment: .leading, spacing: 20) {
                        cameraOff
                        Text("You make the final call.").font(.system(size: 25, weight: .semibold))
                        Text("Confirm the food and preparation, then review its nutrition values in your meal.").lineSpacing(4)
                        Divider()
                        Text("140 g gross − 100 g tare").font(.caption)
                        Text("40 g net food").font(.system(size: 30, weight: .medium))
                        Spacer()
                    }.card().frame(width: 325)
                }
            }
        }
    }
    private var entry: some View {
        Group {
            if !model.confirmed { emptyPrompt("An ingredient comes first.", "Review and confirm a food match before creating a meal.") }
            else {
                HStack(alignment: .top, spacing: 22) {
                    VStack(alignment: .leading, spacing: 20) {
                        eyebrow("MEAL DETAILS")
                        labeledField("Meal name", text: $model.mealName)
                        HStack(spacing: 20) {
                            labeledField("Ingredient", text: $model.foodName)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Net portion").font(.caption)
                                Text("40 g").font(.system(size: 24, weight: .medium))
                            }.frame(width: 100)
                        }
                        Divider()
                        eyebrow("NUTRITION VALUES / PER 100 G")
                        HStack(spacing: 14) {
                            labeledField("Energy · kcal", text: $model.energy)
                            labeledField("Protein · g", text: $model.protein)
                            labeledField("Carbs · g", text: $model.carbs)
                            labeledField("Fat · g", text: $model.fat)
                        }
                        Text("Use values for the same preparation, such as raw or cooked.").font(.caption).foregroundStyle(ink.opacity(0.65))
                        if let error = model.error { Text(error).font(.caption).foregroundStyle(.red) }
                        Spacer()
                    }.card()
                    VStack(alignment: .leading, spacing: 22) {
                        eyebrow("YOUR MEAL / 1 INGREDIENT")
                        Text(model.mealName.isEmpty ? "Untitled meal" : model.mealName).font(.system(size: 25, weight: .semibold))
                        if let totals = model.totals { nutrition(totals, stacked: true) }
                        else { Text("Complete the nutrition values to see an estimate.") }
                        Spacer()
                        Button("Save to history →", action: model.save).buttonStyle(.borderedProminent)
                        Text("Saved for this session").font(.caption).foregroundStyle(ink.opacity(0.65))
                    }.card().frame(width: 325)
                }
            }
        }
    }
    private var history: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack {
                eyebrow("SAVED THIS SESSION")
                Spacer()
                Button("+ New portion") { model.select(.emptyPlate) }.buttonStyle(.bordered)
            }
            if model.meals.isEmpty { emptyPrompt("A fresh page.", "Save a meal to keep its portions here.") }
            else {
                ScrollView {
                    VStack(spacing: 18) {
                        ForEach(model.meals) { meal in
                            VStack(alignment: .leading, spacing: 18) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(meal.name).font(.system(size: 24, weight: .semibold))
                                        Text("\(meal.ingredients.count) ingredient · \(meal.ingredients.first?.name ?? "")").font(.caption).foregroundStyle(ink.opacity(0.65))
                                    }
                                    Spacer()
                                    Text("40 g").font(.system(size: 30, weight: .medium))
                                }
                                Divider()
                                if let total = try? meal.totals() { nutrition(total) }
                                Text("140 g gross − 100 g plate = 40 g food · Source: sample values").font(.caption).foregroundStyle(ink.opacity(0.65))
                            }.card()
                        }
                    }
                }
            }
            Spacer(minLength: 0)
            Text("History stays available while this demo session is open.").font(.caption).foregroundStyle(ink.opacity(0.65))
        }
    }
    private var cameraOff: some View {
        VStack(spacing: 10) {
            Image(systemName: "camera").font(.system(size: 32, weight: .light))
            Text("CAMERA OFF").font(.system(size: 9)).tracking(2)
        }.foregroundStyle(ink.opacity(0.5)).frame(maxWidth: .infinity).padding(22).background(cream).clipShape(RoundedRectangle(cornerRadius: 16))
    }
    private func eyebrow(_ value: String) -> some View { Text(value).font(.system(size: 10, weight: .semibold)).tracking(1.3) }
    private func scaleMetric(_ name: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) { Text(name).font(.system(size: 9)).foregroundStyle(.white.opacity(0.65)); Text(value).font(.system(size: 24)) }
    }
    private func labeledField(_ name: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name).font(.system(size: 12, weight: .medium))
            TextField(name, text: text).textFieldStyle(.roundedBorder).font(.system(size: 17))
        }
    }
    private func nutrition(_ values: Nutrients, stacked: Bool = false) -> some View {
        let items: [(String, Double, String)] = [("Energy", values.energy, "kcal"), ("Protein", values.protein, "g"), ("Carbs", values.carbohydrate, "g"), ("Fat", values.fat, "g")]
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), alignment: .leading), count: stacked ? 2 : 4), alignment: .leading, spacing: 20) {
            ForEach(items, id: \.0) { item in
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(item.1.formatted(.number.precision(.fractionLength(0...1)))) \(item.2)").font(.system(size: 24, weight: .medium))
                    Text(item.0).font(.caption).foregroundStyle(ink.opacity(0.65))
                }
            }
        }
    }
    private func emptyPrompt(_ heading: String, _ text: String) -> some View {
        VStack(spacing: 16) {
            Text(heading).font(.system(size: 27, weight: .semibold))
            Text(text).foregroundStyle(ink.opacity(0.65))
            Button("Go to scale") { model.screen = .weigh }.buttonStyle(.borderedProminent)
        }.frame(maxWidth: .infinity, maxHeight: .infinity).card()
    }
}
private extension View {
    func card() -> some View {
        self.padding(26).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(TrackBiteTheme.paper).clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
