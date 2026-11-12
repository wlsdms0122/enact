// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "enact",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(name: "enact", targets: ["EnactCLI"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
        .package(url: "https://github.com/wlsdms0122/warp-runtime-swift.git", exact: "0.1.0"),
        .package(url: "https://github.com/wlsdms0122/warp-frontend-yaml.git", exact: "0.1.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.1.0")
    ],
    targets: [
        .binaryTarget(name: "IDBPrivateHeaders", path: "Frameworks/IDBPrivateHeaders.xcframework"),
        .binaryTarget(name: "FBControlCoreObjC", path: "Frameworks/FBControlCoreObjC.xcframework"),
        .binaryTarget(name: "FBControlCore", path: "Frameworks/FBControlCore.xcframework"),
        .binaryTarget(name: "SimulatorIPC", path: "Frameworks/SimulatorIPC.xcframework"),
        .binaryTarget(
            name: "FBSimulatorBridgeProtocol",
            path: "Frameworks/FBSimulatorBridgeProtocol.xcframework"
        ),
        .binaryTarget(name: "FBSimulatorControl", path: "Frameworks/FBSimulatorControl.xcframework"),
        .binaryTarget(
            name: "FBSimulatorServices",
            path: "Frameworks/FBSimulatorServices.xcframework"
        ),
        .binaryTarget(name: "FBSimulatorAX", path: "Frameworks/FBSimulatorAX.xcframework"),
        .binaryTarget(name: "FBVideoCore", path: "Frameworks/FBVideoCore.xcframework"),
        .binaryTarget(name: "FBSimulatorVideo", path: "Frameworks/FBSimulatorVideo.xcframework"),
        .target(
            name: "Digit",
            dependencies: [
                "IDBPrivateHeaders",
                "FBControlCoreObjC",
                "FBControlCore",
                "SimulatorIPC",
                "FBSimulatorBridgeProtocol",
                "FBSimulatorControl",
                "FBSimulatorServices",
                "FBSimulatorAX",
                "FBVideoCore",
                "FBSimulatorVideo"
            ],
            // The idb libraries are static archives. `-ObjC` keeps their categories, which
            // define no symbol the linker would pull them in for, and the private frameworks
            // they call are weak-linked here, as no dylib of theirs carries the link. The
            // section is the guest `SimulatorFrameworkBridge` writes out.
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-ObjC",
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__sim_bridge",
                    "-Xlinker",
                    "\(Context.packageDirectory)/Frameworks/SimulatorFrameworkBridge-iOS",
                    "-Xlinker", "-F", "-Xlinker", "/Library/Developer/PrivateFrameworks",
                    "-Xlinker", "-weak_framework", "-Xlinker", "CoreSimulator",
                    "-Xlinker", "-F", "-Xlinker", "/System/Library/PrivateFrameworks",
                    "-Xlinker", "-weak_framework", "-Xlinker", "AccessibilityPlatformTranslation"
                ])
            ]
        ),
        .target(
            name: "EnactWarp",
            dependencies: [
                "Digit",
                .product(name: "Warp", package: "warp-runtime-swift"),
                .product(name: "WarpSyntax", package: "warp-runtime-swift"),
                .product(name: "WarpStandard", package: "warp-runtime-swift"),
                .product(name: "WarpYAML", package: "warp-frontend-yaml"),
                .product(name: "Yams", package: "Yams")
            ]
        ),
        .target(
            name: "Enact",
            dependencies: [
                "Digit",
                "EnactWarp",
                .product(name: "Warp", package: "warp-runtime-swift"),
                .product(name: "WarpSyntax", package: "warp-runtime-swift"),
                .product(name: "WarpYAML", package: "warp-frontend-yaml")
            ]
        ),
        .target(
            name: "DigitCLI",
            dependencies: [
                "Digit",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .executableTarget(
            name: "EnactCLI",
            dependencies: [
                "DigitCLI",
                "Enact",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(name: "DigitTests", dependencies: ["Digit"]),
        .testTarget(name: "DigitCLITests", dependencies: ["DigitCLI"]),
        .testTarget(name: "EnactWarpTests", dependencies: ["EnactWarp"]),
        .testTarget(name: "EnactTests", dependencies: ["Enact"]),
        .testTarget(name: "EnactCLITests", dependencies: ["EnactCLI"])
    ]
)
