// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "FLEX",
  platforms: [.iOS(.v12)],
  products: [
    .library(
      name: "FLEX",
      targets: [
        "FLEX",
      ]
    ),
  ],

  targets: [
    .binaryTarget(
      name: "FLEX",
      url: "https://github.com/exception7601/FLEX/releases/download/5.22.10.1770064284/FLEX-e34d20ddc2c9d1f4.zip",
      checksum: "e25a6465154fb2853ae05a6b66afcfd54fe7450c612c4a5d07ff9562e23f9e0f"
    )
  ]
)
