import Foundation

public enum MealError: LocalizedError {
    case invalidName, invalidWeight, invalidNutrients, emptyMeal, duplicateID, missingMeal

    public var errorDescription: String? {
        switch self {
        case .invalidName: return "Enter a meal and ingredient name."
        case .invalidWeight: return "Enter a finite weight greater than zero, in grams."
        case .invalidNutrients: return "Nutrition values must be finite and nonnegative, and totals must fit within the supported numeric range."
        case .emptyMeal: return "Add at least one ingredient before saving."
        case .duplicateID: return "Duplicate identifiers were found in the meal log."
        case .missingMeal: return "This meal is no longer in the log."
        }
    }
}

/// Energy is kcal; protein, carbohydrate and fat are grams.
public struct Nutrients: Codable, Equatable {
    public let energy: Double
    public let protein: Double
    public let carbohydrate: Double
    public let fat: Double

    public init(energy: Double = 0, protein: Double = 0, carbohydrate: Double = 0, fat: Double = 0) {
        self.energy = energy
        self.protein = protein
        self.carbohydrate = carbohydrate
        self.fat = fat
    }

    public func validate() throws {
        guard [energy, protein, carbohydrate, fat].allSatisfy({ $0.isFinite && $0 >= 0 }) else {
            throw MealError.invalidNutrients
        }
    }

    public func scaled(by factor: Double) throws -> Nutrients {
        try validate()
        guard factor.isFinite, factor >= 0 else { throw MealError.invalidWeight }
        let result = Nutrients(energy: energy * factor, protein: protein * factor,
                               carbohydrate: carbohydrate * factor, fat: fat * factor)
        try result.validate()
        return result
    }

    public func adding(_ other: Nutrients) throws -> Nutrients {
        try validate()
        try other.validate()
        let result = Nutrients(energy: energy + other.energy, protein: protein + other.protein,
                               carbohydrate: carbohydrate + other.carbohydrate, fat: fat + other.fat)
        try result.validate()
        return result
    }
}

public struct Ingredient: Codable, Equatable, Identifiable {
    public let id: UUID
    public let name: String
    public let grams: Double
    public let per100g: Nutrients

    public init(id: UUID = UUID(), name: String, grams: Double, per100g: Nutrients) {
        self.id = id
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.grams = grams
        self.per100g = per100g
    }

    public func totals() throws -> Nutrients {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw MealError.invalidName }
        guard grams.isFinite, grams > 0 else { throw MealError.invalidWeight }
        return try per100g.scaled(by: grams / 100)
    }
}

public struct Meal: Codable, Equatable, Identifiable {
    public let id: UUID
    public let name: String
    public let savedAt: Date
    public let ingredients: [Ingredient]

    public init(id: UUID = UUID(), name: String, savedAt: Date = Date(), ingredients: [Ingredient]) {
        self.id = id
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.savedAt = savedAt
        self.ingredients = ingredients
    }

    public func totals() throws -> Nutrients {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw MealError.invalidName }
        guard !ingredients.isEmpty else { throw MealError.emptyMeal }
        guard Set(ingredients.map(\.id)).count == ingredients.count else { throw MealError.duplicateID }
        return try ingredients.reduce(Nutrients()) { try $0.adding($1.totals()) }
    }
}
