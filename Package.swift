// swift-tools-version: 6.0

import PackageDescription

let package = Package(

  name: "FLEX",
  platforms: [.iOS(.v15)],
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
      url: "https://github.com/exception7601/FLEX/releases/download/5.22.10.1740069166/FLEX-78160781b683ef5f.zip",
      checksum: "c7828d9302afd2aba98d61b133fa704920af844e3da9b7514d66d84e4de93755"
    )
  ]
)
