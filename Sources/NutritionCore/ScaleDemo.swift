import Foundation

public enum ScaleError: Error { case invalidReading, negativeNet, unconfirmedFood, unavailable }

/// A value snapshot. Demo fixtures never imply that a sensor was read.
public struct ScaleReading: Equatable {
    public let gross: Double
    public let tare: Double
    public var net: Double { gross - tare }
    public init(gross: Double, tare: Double) throws {
        guard gross.isFinite, tare.isFinite, gross >= 0, tare >= 0 else { throw ScaleError.invalidReading }
        guard gross >= tare else { throw ScaleError.negativeNet }
        self.gross = gross
        self.tare = tare
    }
}
public enum DemoScenario: String, CaseIterable {
    case emptyPlate, plateAndFood
    public var reading: ScaleReading {
        // Constants validated in focused checks; no device access occurs.
        try! ScaleReading(gross: self == .emptyPlate ? 100 : 140, tare: 100)
    }
}
public protocol ScaleAdapter {
    var isSimulated: Bool { get }
    func snapshot(for scenario: DemoScenario) throws -> ScaleReading
}
public struct MockScaleAdapter: ScaleAdapter {
    public init() {}
    public let isSimulated = true
    public func snapshot(for scenario: DemoScenario) throws -> ScaleReading { scenario.reading }
}
/// Intentionally fails closed. No framework imports, permission prompts or listeners.
public struct UnavailableTrackpadAdapter: ScaleAdapter {
    public init() {}
    public let isSimulated = false
    public func snapshot(for scenario: DemoScenario) throws -> ScaleReading { throw ScaleError.unavailable }
}
public struct FoodCandidate {
    public let name: String
    public let per100g: Nutrients
    public let isSimulated: Bool
    public init(name: String, per100g: Nutrients, isSimulated: Bool) {
        self.name = name; self.per100g = per100g; self.isSimulated = isSimulated
    }
    public func ingredient(reading: ScaleReading, confirmed: Bool) throws -> Ingredient {
        guard confirmed else { throw ScaleError.unconfirmedFood }
        let result = Ingredient(name: name, grams: reading.net, per100g: per100g)
        _ = try result.totals()
        return result
    }
}
public protocol FoodIdentificationAdapter {
    func previewCandidate() throws -> FoodCandidate
}
/// Fictional example values for workflow testing; no photo ingestion.
public struct MockFoodIdentificationAdapter: FoodIdentificationAdapter {
    public init() {}
    public func previewCandidate() throws -> FoodCandidate {
        FoodCandidate(name: "Example food", per100g: Nutrients(energy: 50, protein: 2, carbohydrate: 8, fat: 1), isSimulated: true)
    }
}
