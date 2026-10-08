import SwiftUI
import NutritionCore

@main
struct TrackBiteApp: App {
    @StateObject private var model = MealViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(model: model).frame(minWidth: 760, minHeight: 560)
        }
    }
}

@MainActor
final class MealViewModel: ObservableObject {
    @Published var mealName = ""
    @Published private(set) var ingredients: [Ingredient] = []
    @Published private(set) var meals: [Meal] = []
    @Published var errorMessage: String?
    @Published var confirmation: String?
    private var store: MealLogStore?

    var canSave: Bool { store != nil }
    var draftTotals: Nutrients? {
        try? ingredients.reduce(Nutrients()) { try $0.adding($1.totals()) }
    }

    init() {
        do {
            let support = try FileManager.default.url(for: .applicationSupportDirectory,
                                                      in: .userDomainMask,
                                                      appropriateFor: nil, create: false)
            store = try MealLogStore(fileURL: support.appendingPathComponent("TrackBite", isDirectory: true)
                .appendingPathComponent("meals.json"))
            meals = store?.meals ?? []
        } catch {
            errorMessage = "Could not read the saved meal log. The file was left untouched; saving is disabled until it is repaired or restored and the app reopened."
        }
    }

    func setIngredient(_ ingredient: Ingredient) throws {
        _ = try ingredient.totals()
        var next = ingredients
        if let index = next.firstIndex(where: { $0.id == ingredient.id }) { next[index] = ingredient }
        else { next.append(ingredient) }
        _ = try next.reduce(Nutrients()) { try $0.adding($1.totals()) }
        ingredients = next
        confirmation = nil
    }

    func removeIngredient(_ ingredient: Ingredient) {
        ingredients.removeAll { $0.id == ingredient.id }
        confirmation = nil
    }

    func saveMeal() {
        guard var next = store else { return }
        do {
            try next.append(Meal(name: mealName, ingredients: ingredients))
            store = next
            meals = next.meals
            ingredients = []
            mealName = ""
            errorMessage = nil
            confirmation = "Meal saved. Open Meal log to review it."
        } catch let error as MealError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Could not save the meal. Your draft is still here; the previous log is unchanged."
        }
    }

    func deleteMeal(_ meal: Meal) {
        guard var next = store else { return }
        do {
            try next.delete(id: meal.id)
            store = next
            meals = next.meals
            errorMessage = nil
            confirmation = nil
        } catch {
            errorMessage = "Could not delete the meal. The previous log is still shown."
        }
    }
}
