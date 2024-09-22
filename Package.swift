// swift-tools-version: 5.10

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "EnumCaseLabeling",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "EnumCaseLabeling",
            targets: ["EnumCaseLabeling"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "510.0.0"),
    ],
    targets: [
        .macro(
            name: "EnumCaseLabelingMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),

        .target(name: "EnumCaseLabeling", dependencies: ["EnumCaseLabelingMacros"]),

        .testTarget(
            name: "EnumCaseLabelingTests",
            dependencies: [
                "EnumCaseLabeling",
                "EnumCaseLabelingMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
