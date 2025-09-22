ROOT=".build/xcframeworks"
FRAMEWORK_PATH="Products/Library/Frameworks/FLEX.framework"
PLATAFORMS=("iOS" "iOS Simulator")

# Remover xcframeworks
VERSION=5.22.10
REPO=exception7601/FLEX
ARCHIVE_NAME=FLEX
FRAMEWORK_NAME=FLEX
ORIGIN=$(pwd)
set -e  # Saia no primeiro erro
JSON_FILE="Carthage/FLEXBinary.json"
BUILD=$(date +%s) 
BUILD_COMMIT=$(git log --oneline --abbrev=16 --pretty=format:"%h" -1)
NEW_VERSION=${VERSION}.${BUILD}
NAME=FLEX-${BUILD_COMMIT}.zip

rm -rf $ROOT

for PLATAFORM in "${PLATAFORMS[@]}"
do
xcodebuild archive \
    -project "$FRAMEWORK_NAME.xcodeproj" \
    -scheme "$FRAMEWORK_NAME" \
    -destination "generic/platform=$PLATAFORM"\
    -archivePath "$ROOT/$ARCHIVE_NAME-$PLATAFORM.xcarchive" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    DEBUG_INFORMATION_FORMAT=DWARF
done

xcodebuild -create-xcframework \
  -framework "$ROOT/$ARCHIVE_NAME-iOS.xcarchive/$FRAMEWORK_PATH" \
  -framework "$ROOT/$ARCHIVE_NAME-iOS Simulator.xcarchive/$FRAMEWORK_PATH" \
   -output "$ROOT/$FRAMEWORK_NAME.xcframework"

# Entre no diretório temporariamente
cd "$ROOT"

# Crie o arquivo zip
# mkdir "$ARCHIVE_NAME"
# cp -R "$FRAMEWORK_NAME.xcframework" "$ARCHIVE_NAME"
zip -r -X "$NAME" "$FRAMEWORK_NAME.xcframework/"
mv "$NAME" "$ORIGIN"
rm -rf *.xcframework
cd "$ORIGIN"

# Upload Version in Github
SUM=$(swift package compute-checksum ${NAME} )
echo $NEW_VERSION > version

DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${NEW_VERSION}/${NAME}"

if [ ! -f $JSON_FILE ]; then
  echo "{}" > $JSON_FILE
fi

# Make Carthage
JSON_CARTHAGE="$(jq --arg version "${VERSION}" --arg url "${DOWNLOAD_URL}" '. + { ($version): $url }' $JSON_FILE)" 
echo $JSON_CARTHAGE > $JSON_FILE

PACKAGE=$(cat <<END
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
      url: "${DOWNLOAD_URL}",
      checksum: "${SUM}"
    )
  ]
)
END
)

echo "$PACKAGE" > Package.swift
git add Package.swift

git add version $JSON_FILE
git commit -m "new Version ${NEW_VERSION}"
git tag -s -a ${NEW_VERSION} -m "v${NEW_VERSION}"
# git checkout -b release-v${VERSION}
git push origin HEAD --tags
gh release create ${NEW_VERSION} ${NAME} --notes "checksum \`${SUM}\`"

URL=$(gh release view ${NEW_VERSION} \
  --repo ${REPO} \
  --json assets \
  -q ".assets[] | select(.name == \"${NAME}\").url"
)

NOTES=$(cat <<END
Carthage
\`\`\`
binary "https://raw.githubusercontent.com/${REPO}/main/${JSON_FILE}"
\`\`\`

Install
\`\`\`
carthage bootstrap --use-xcframeworks
\`\`\`
END
)

gh release edit ${NEW_VERSION} --notes  "${NOTES}"
echo "${NOTES}"
