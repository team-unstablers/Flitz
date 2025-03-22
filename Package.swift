
// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flitz",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "flitz",
            targets: ["flitz"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.2")),
        .package(url: "https://github.com/Alamofire/AlamofireImage", .upToNextMajor(from: "4.3.0")),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.1.4")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "flitz",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "AlamofireImage", package: "AlamofireImage"),
                .product(name: "Collections", package: "swift-collections"),
            ],
            path: "flitz"
        ),
    ]
)


