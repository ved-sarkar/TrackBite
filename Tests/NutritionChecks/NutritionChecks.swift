import Foundation
import NutritionCore

private struct CheckFailure: Error, CustomStringConvertible {
    let description: String
}

private func expect(_ condition: Bool, _ message: String) throws {
    guard condition else { throw CheckFailure(description: message) }
}

private func expectClose(_ actual: Double, _ expected: Double) throws {
    try expect(abs(actual - expected) < 0.000_001, "Expected \(expected), got \(actual)")
}

private func expectThrows<T>(_ action: @autoclosure () throws -> T) throws {
    do { _ = try action() }
    catch { return }
    throw CheckFailure(description: "Expected operation to reject invalid input")
}

private func withTemporaryStore(_ body: (URL) throws -> Void) throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    try body(directory.appendingPathComponent("meals.json"))
}

private func fixture() -> Meal {
    // Fictional arithmetic inputs, not a food composition dataset.
    Meal(name: "Fictional meal", savedAt: Date(timeIntervalSince1970: 1000), ingredients: [
        Ingredient(name: "Ingredient A", grams: 50,
                   per100g: Nutrients(energy: 200, protein: 10, carbohydrate: 20, fat: 5)),
        Ingredient(name: "Ingredient B", grams: 125,
                   per100g: Nutrients(energy: 80, protein: 4, carbohydrate: 12, fat: 2))
    ])
}

@main
struct NutritionChecks {
    static func main() throws {
        let checks: [(String, () throws -> Void)] = [
            ("Per-100g scaling and mixed-meal totals", calculation),
            ("Invalid weights, nutrients, names and empty meals", validation),
            ("Overflow and duplicate ingredient rejection", overflow),
            ("Saved inputs and totals survive reload and deletion", persistence),
            ("Malformed and duplicate logs remain untouched", invalidLogs),
            ("Failed writes and rejected saves preserve prior state", failedWrites)
        ]
        for (name, check) in checks {
            try check()
            print("PASS: \(name)")
        }
        print("All \(checks.count) nutrition checks passed.")
    }

    static func calculation() throws {
        let meal = fixture()
        let single = try meal.ingredients[0].totals()
        try expectClose(single.energy, 100)
        try expectClose(single.protein, 5)
        let total = try meal.totals()
        try expectClose(total.energy, 200)
        try expectClose(total.protein, 10)
        try expectClose(total.carbohydrate, 25)
        try expectClose(total.fat, 5)
        let waterLike = Ingredient(name: "Fictional zero-nutrient input", grams: 100, per100g: Nutrients())
        try expect(try waterLike.totals() == Nutrients(), "Zero nutrient values should be allowed")
    }

    static func validation() throws {
        for grams in [0, -1, Double.nan, Double.infinity] {
            try expectThrows(try Ingredient(name: "Example", grams: grams, per100g: Nutrients()).totals())
        }
        for values in [Nutrients(energy: -1), Nutrients(protein: .nan),
                       Nutrients(carbohydrate: .infinity), Nutrients(fat: -0.1)] {
            try expectThrows(try Ingredient(name: "Example", grams: 100, per100g: values).totals())
        }
        try expectThrows(try Ingredient(name: " \n", grams: 10, per100g: Nutrients()).totals())
        try expectThrows(try Meal(name: "", ingredients: fixture().ingredients).totals())
        try expectThrows(try Meal(name: "Empty", ingredients: []).totals())
    }

    static func overflow() throws {
        try expectThrows(try Ingredient(name: "Overflow", grams: 1e308,
                                       per100g: Nutrients(energy: 1e308)).totals())
        let largeA = Ingredient(name: "Large A", grams: 100, per100g: Nutrients(energy: 1e308))
        let largeB = Ingredient(name: "Large B", grams: 100, per100g: Nutrients(energy: 1e308))
        try expectThrows(try Meal(name: "Overflow sum", ingredients: [largeA, largeB]).totals())
        let item = fixture().ingredients[0]
        try expectThrows(try Meal(name: "Duplicate", ingredients: [item, item]).totals())
    }

    static func persistence() throws {
        try withTemporaryStore { file in
            var store = try MealLogStore(fileURL: file)
            let meal = fixture()
            try store.append(meal)
            let reloaded = try MealLogStore(fileURL: file)
            try expect(reloaded.meals == [meal], "Save must preserve all entered values and identifiers")
            try expectClose(try reloaded.meals[0].totals().energy, 200)
            try store.delete(id: meal.id)
            try expect(try MealLogStore(fileURL: file).meals.isEmpty, "Deletion should persist")
        }
    }

    static func invalidLogs() throws {
        try withTemporaryStore { file in
            let broken = Data("not a meal log".utf8)
            try broken.write(to: file)
            try expectThrows(try MealLogStore(fileURL: file))
            try expect(try Data(contentsOf: file) == broken, "Corrupt input was overwritten")
            let meal = fixture()
            let duplicate = try JSONEncoder().encode([meal, meal])
            try duplicate.write(to: file)
            try expectThrows(try MealLogStore(fileURL: file))
            try expect(try Data(contentsOf: file) == duplicate, "Duplicate input was overwritten")
            let invalid = Meal(name: "Invalid input", ingredients: [
                Ingredient(name: "Example", grams: -1, per100g: Nutrients())
            ])
            try JSONEncoder().encode([invalid]).write(to: file)
            try expectThrows(try MealLogStore(fileURL: file))
        }
    }

    static func failedWrites() throws {
        try withTemporaryStore { file in
            var store = try MealLogStore(fileURL: file)
            let meal = fixture()
            try store.append(meal)
            let original = try Data(contentsOf: file)
            try expectThrows(try store.append(meal))
            try expectThrows(try store.append(Meal(name: "Empty", ingredients: [])))
            try expect(store.meals == [meal], "Rejected save changed memory")
            try expect(try Data(contentsOf: file) == original, "Rejected save changed disk")
            let blocker = file.deletingLastPathComponent().appendingPathComponent("blocker")
            try Data("fictional blocker".utf8).write(to: blocker)
            var blocked = try MealLogStore(fileURL: blocker.appendingPathComponent("meals.json"))
            try expectThrows(try blocked.append(meal))
            try expect(blocked.meals.isEmpty, "Failed write changed memory")
        }
    }
}
