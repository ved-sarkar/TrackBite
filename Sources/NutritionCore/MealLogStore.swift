import Foundation

/// Saves ingredient inputs as snapshots, so totals remain reproducible after reload.
public struct MealLogStore {
    public private(set) var meals: [Meal]
    public let fileURL: URL

    public init(fileURL: URL) throws {
        self.fileURL = fileURL
        if FileManager.default.fileExists(atPath: fileURL.path) {
            meals = try JSONDecoder().decode([Meal].self, from: Data(contentsOf: fileURL))
            try Self.validate(meals)
        } else {
            meals = []
        }
    }

    public mutating func append(_ meal: Meal) throws { try persist(meals + [meal]) }

    public mutating func delete(id: UUID) throws {
        guard meals.contains(where: { $0.id == id }) else { throw MealError.missingMeal }
        try persist(meals.filter { $0.id != id })
    }

    private static func validate(_ meals: [Meal]) throws {
        guard Set(meals.map(\.id)).count == meals.count else { throw MealError.duplicateID }
        for meal in meals {
            _ = try meal.totals()
            guard meal.savedAt.timeIntervalSince1970.isFinite else { throw MealError.invalidNutrients }
        }
    }

    private mutating func persist(_ next: [Meal]) throws {
        try Self.validate(next)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(next)
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(),
                                                withIntermediateDirectories: true)
        try data.write(to: fileURL, options: .atomic)
        meals = next
    }
}
