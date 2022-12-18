// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "FirePhone",
  platforms: [.iOS("14.0"), .tvOS("14.0")],
  products: [
    .library(
      name: "FirePhone",
      targets: ["FirePhone"]),
  ],
  dependencies: [
    .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: "3.3.0"),
    .package(name: "Firebase", url: "https://github.com/firebase/firebase-ios-sdk", from: "10.0.0"),
  ],
  targets: [

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
