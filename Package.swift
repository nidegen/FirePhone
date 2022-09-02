// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "FirePhone",
  platforms: [.iOS("14.0"), .tvOS("14.0"), .macOS("11.0")],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "FirePhone",
      targets: ["FirePhone"]),
  ],
  dependencies: [
    .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: "3.3.0"),
    .package(name: "Firebase", path: "../../TMP/firebase-ios-sdk"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "FirePhone",
      dependencies: [
        "PhoneNumberKit",
        .product(name: "FirebaseAuth", package: "Firebase"),
      ]),
    .testTarget(
      name: "FirePhoneTests",
      dependencies: ["FirePhone"]),
  ]
)
