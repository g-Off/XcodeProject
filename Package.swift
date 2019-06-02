// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "XcodeProject",
	platforms: [
		.macOS(.v10_14)
	],
    products: [
        .library(
            name: "XcodeProject",
            targets: ["XcodeProject"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "XcodeProject",
            dependencies: []),
        .testTarget(
            name: "XcodeProjectTests",
            dependencies: ["XcodeProject"]),
    ]
)
