// swift-tools-version: 6.0

import CompilerPluginSupport
import PackageDescription

let defaultSwiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
]

let package = Package(
    name: "EnumCaseLabeling",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
        .macCatalyst(.v16),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "EnumCaseLabeling",
            targets: ["EnumCaseLabeling"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", "600.0.0"..<"604.0.0"),
    ],
    targets: [
        .macro(
            name: "EnumCaseLabelingMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
            swiftSettings: defaultSwiftSettings
        ),
        .target(
            name: "EnumCaseLabeling",
            dependencies: ["EnumCaseLabelingMacros"],
            swiftSettings: defaultSwiftSettings
        ),
        .testTarget(
            name: "EnumCaseLabelingTests",
            dependencies: [
                "EnumCaseLabeling",
                "EnumCaseLabelingMacros",
                .product(name: "SwiftSyntaxMacroExpansion", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosGenericTestSupport", package: "swift-syntax"),
            ],
            swiftSettings: defaultSwiftSettings
        ),
    ]
)
