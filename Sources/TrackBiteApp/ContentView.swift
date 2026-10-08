import SwiftUI
import NutritionCore

struct ContentView: View {
    @ObservedObject var model: MealViewModel
    @State private var editor: IngredientDraft?
    @State private var pendingDeletion: Meal?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TrackBite").font(.largeTitle.bold())
                    Text("Build a meal from the weights and nutrition values you enter.")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Label("Manual weight", systemImage: "scalemass").font(.callout)
            }
            Text("Enter weights in grams. Trackpad capture and camera recognition are not connected.")
                .font(.caption).foregroundStyle(.secondary)
            if let error = model.errorMessage { Text(error).foregroundStyle(.red) }
            if let message = model.confirmation { Text(message).foregroundStyle(.green) }
            TabView {
                draft.tabItem { Label("New meal", systemImage: "plus.circle") }
                log.tabItem { Label("Meal log", systemImage: "list.bullet.rectangle") }
            }
            Text("Estimates from your entries · Stored on this Mac · No photos or network requests")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(20)
        .sheet(item: $editor) { draft in
            IngredientEditor(draft: draft, save: model.setIngredient)
        }
        .alert("Delete this saved meal?", isPresented: Binding(
            get: { pendingDeletion != nil }, set: { if !$0 { pendingDeletion = nil } }
        )) {
            Button("Cancel", role: .cancel) { pendingDeletion = nil }
            Button("Delete", role: .destructive) {
                if let meal = pendingDeletion { model.deleteMeal(meal) }
                pendingDeletion = nil
            }
        } message: { Text("This removes the meal from the local log.") }
    }

    private var draft: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TextField("Meal name", text: $model.mealName).textFieldStyle(.roundedBorder)
                Button { editor = IngredientDraft() } label: { Label("Add ingredient", systemImage: "plus") }
            }
            if model.ingredients.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "fork.knife.circle").font(.system(size: 38))
                    Text("Start with one ingredient").font(.title2)
                    Text("Use a package label or your own reference for values per 100 g.")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(model.ingredients) { ingredient in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ingredient.name).font(.headline)
                            Text("\(ingredient.grams.formatted(.number.precision(.fractionLength(0...2)))) g")
                                .foregroundStyle(.secondary)
                            if let values = try? ingredient.totals() { NutritionSummary(values: values) }
                        }
                        Spacer()
                        Button("Edit") { editor = IngredientDraft(ingredient) }
                        Button { model.removeIngredient(ingredient) } label: { Image(systemName: "minus.circle") }
                            .accessibilityLabel("Remove \(ingredient.name) from draft")
                    }
                    .padding(.vertical, 5).buttonStyle(.borderless)
                }
            }
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Estimated meal totals").font(.headline)
                    if let values = model.draftTotals { NutritionSummary(values: values) }
                }
                Spacer()
                Button("Save meal", action: model.saveMeal)
                    .disabled(!model.canSave || model.ingredients.isEmpty || model.mealName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            Text("The unsaved draft is cleared when the app closes.").font(.caption).foregroundStyle(.secondary)
        }.padding(14)
    }

    private var log: some View {
        Group {
            if model.meals.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "book.closed").font(.system(size: 36))
                    Text("No saved meals yet").font(.title2)
                    Text("Save a meal to keep its ingredients and estimates here.").foregroundStyle(.secondary)
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(model.meals.sorted { $0.savedAt > $1.savedAt }) { meal in
                    DisclosureGroup {
                        ForEach(meal.ingredients) { ingredient in
                            VStack(alignment: .leading, spacing: 3) {
                                Text("\(ingredient.name) · \(ingredient.grams.formatted()) g").font(.headline)
                                Text("Entered values per 100 g:").font(.caption).foregroundStyle(.secondary)
                                NutritionSummary(values: ingredient.per100g)
                            }.padding(.vertical, 4)
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(meal.name).font(.headline)
                                Text(meal.savedAt, format: .dateTime.year().month().day().hour().minute())
                                    .font(.caption).foregroundStyle(.secondary)
                                if let values = try? meal.totals() { NutritionSummary(values: values) }
                            }
                            Spacer()
                            Button(role: .destructive) { pendingDeletion = meal } label: { Image(systemName: "trash") }
                                .accessibilityLabel("Delete \(meal.name)").buttonStyle(.borderless)
                        }
                    }.padding(.vertical, 5)
                }
            }
        }.padding(14)
    }
}

private struct NutritionSummary: View {
    let values: Nutrients
    private func number(_ value: Double) -> String { value.formatted(.number.precision(.fractionLength(0...1))) }
    var body: some View {
        Text("\(number(values.energy)) kcal · Protein \(number(values.protein)) g · Carbs \(number(values.carbohydrate)) g · Fat \(number(values.fat)) g")
            .font(.callout).foregroundStyle(.secondary)
    }
}

private struct IngredientDraft: Identifiable {
    var id: UUID
    var name: String
    var grams: String
    var energy: String
    var protein: String
    var carbohydrate: String
    var fat: String

    init(_ item: Ingredient? = nil) {
        id = item?.id ?? UUID()
        name = item?.name ?? ""
        grams = item.map { String($0.grams) } ?? ""
        energy = item.map { String($0.per100g.energy) } ?? ""
        protein = item.map { String($0.per100g.protein) } ?? ""
        carbohydrate = item.map { String($0.per100g.carbohydrate) } ?? ""
        fat = item.map { String($0.per100g.fat) } ?? ""
    }

    func ingredient() throws -> Ingredient {
        let strings = [grams, energy, protein, carbohydrate, fat]
        let numbers = strings.compactMap { Double($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
        guard numbers.count == strings.count else { throw EntryError() }
        return Ingredient(id: id, name: name, grams: numbers[0],
                          per100g: Nutrients(energy: numbers[1], protein: numbers[2], carbohydrate: numbers[3], fat: numbers[4]))
    }
}

private struct EntryError: LocalizedError {
    var errorDescription: String? { "Enter all numeric values using a decimal point. Zero is allowed for nutrients." }
}

private struct IngredientEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State var draft: IngredientDraft
    @State private var error: String?
    let save: (Ingredient) throws -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ingredient details").font(.title2.bold())
            Form {
                TextField("Name", text: $draft.name)
                TextField("Weight in grams", text: $draft.grams)
                Section("Nutrition per 100 g — enter your label values") {
                    TextField("Energy (kcal)", text: $draft.energy)
                    TextField("Protein (g)", text: $draft.protein)
                    TextField("Carbohydrate (g)", text: $draft.carbohydrate)
                    TextField("Fat (g)", text: $draft.fat)
                }
            }
            Text("Use values and weights on the same basis, such as both cooked or both raw. Estimates depend on the values you enter.")
                .font(.caption).foregroundStyle(.secondary)
            if let error { Text(error).foregroundStyle(.red) }
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }.keyboardShortcut(.cancelAction)
                Button("Use ingredient") {
                    do { try save(draft.ingredient()); dismiss() }
                    catch { self.error = error.localizedDescription }
                }.keyboardShortcut(.defaultAction)
            }
        }.padding(24).frame(width: 500)
    }
}
