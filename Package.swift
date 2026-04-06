// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FloatingKeyboard",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "FloatingKeyboard",
            path: "Sources/FloatingKeyboard",
            linkerSettings: [
                .linkedFramework("Cocoa"),
                .linkedFramework("Carbon"),
            ]
        ),
    ]
)
