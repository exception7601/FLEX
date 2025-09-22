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
      url: "https://github.com/exception7601/FLEX/releases/download/5.22.10.1758565135/FLEX-64aa7f014bd07313.zip",
      checksum: "35348a7f80c64ab9e1ba3adbbaaba148c29f37e91b1bce5108d35c9ef248416b"
    )
  ]
)
