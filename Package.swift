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
		.package(url: "https://github.com/g-Off/ObjectCoder.git", .exact("0.1.0")),
		.package(url: "https://github.com/mxcl/Version.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "XcodeProject",
            dependencies: ["ObjectCoder", "Version"]),
        .testTarget(
            name: "XcodeProjectTests",
            dependencies: ["XcodeProject"]),
    ]
)
