import Foundation
import SwiftUI
import NutritionCore

enum StudioScreen: String, CaseIterable {
    case weigh = "Weigh", identify = "Identify", entry = "Meal entry", history = "History"
    var number: Int { Self.allCases.firstIndex(of: self)! + 1 }
}

@MainActor
final class DemoStudioModel: ObservableObject {
    @Published var screen: StudioScreen = .weigh
    @Published private(set) var scenario: DemoScenario = .emptyPlate
    @Published private(set) var candidate: FoodCandidate?
    @Published private(set) var confirmed = false
    @Published var mealName = "Afternoon snack"
    @Published var foodName = "Example food"
    @Published var energy = "50"
    @Published var protein = "2"
    @Published var carbs = "8"
    @Published var fat = "1"
    @Published private(set) var meals: [Meal] = []
    @Published var error: String?
    private let identifier = MockFoodIdentificationAdapter()
    var reading: ScaleReading { scenario.reading }
    var hasFood: Bool { scenario == .plateAndFood }
    var totals: Nutrients? { try? draftIngredient().totals() }

    func select(_ next: DemoScenario) {
        scenario = next; candidate = nil; confirmed = false; error = nil; screen = .weigh
    }
    func identify() {
        guard hasFood else { return }
        candidate = try? identifier.previewCandidate()
        confirmed = false; error = nil; screen = .identify
    }
    func confirm() {
        guard let candidate else { return }
        do {
            let ingredient = try candidate.ingredient(reading: reading, confirmed: true)
            foodName = ingredient.name; energy = "50"; protein = "2"; carbs = "8"; fat = "1"
            confirmed = true; error = nil; screen = .entry
        } catch { self.error = "Choose a valid portion before continuing." }
    }
    func draftIngredient() throws -> Ingredient {
        guard confirmed else { throw ScaleError.unconfirmedFood }
        let fields = [energy, protein, carbs, fat]
        let values = fields.compactMap { Double($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
        guard values.count == 4 else { throw MealError.invalidNutrients }
        return Ingredient(name: foodName, grams: reading.net,
            per100g: Nutrients(energy: values[0], protein: values[1], carbohydrate: values[2], fat: values[3]))
    }
    func save() {
        do {
            let meal = Meal(name: mealName, ingredients: [try draftIngredient()])
            _ = try meal.totals()
            meals.insert(meal, at: 0)
            confirmed = false; error = nil; screen = .history
        } catch { self.error = "Enter a meal name, ingredient name and finite, nonnegative nutrition values." }
    }
}
