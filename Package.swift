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
      url: "https://github.com/exception7601/FLEX/releases/download/5.22.10.1770064732/FLEX-f0719eedc24db1de.zip",
      checksum: "e7d18abe50d3f8227d482f8bae6dddbd33e000b0756ae1c671bf1628602a4c9b"
    )
  ]
)
