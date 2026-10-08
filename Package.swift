// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TrackBite",
    platforms: [.macOS(.v13)],
    products: [.executable(name: "TrackBite", targets: ["TrackBiteApp"])],
    targets: [
        .target(name: "NutritionCore"),
        .executableTarget(name: "TrackBiteApp", dependencies: ["NutritionCore"]),
        .executableTarget(name: "NutritionChecks", dependencies: ["NutritionCore"], path: "Tests/NutritionChecks")
    ]
)
