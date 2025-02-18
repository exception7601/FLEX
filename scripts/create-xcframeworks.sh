ROOT=".build/xcframeworks"
FRAMEWORK_PATH="Products/Library/Frameworks/FLEX.framework"
PLATAFORMS=("iOS" "iOS Simulator")
NAME=Flex.xcframework.zip
VERSION=5.22.10
REPO=exception7601/FLEX
ARCHIVE_NAME=flex
FRAMEWORK_NAME=FLEX
ORIGIN=$(pwd)
set -e  # Saia no primeiro erro
JSON_FILE="Carthage/FLEXBinary.json"

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

# # Crie o arquivo zip
zip -rX "$NAME" "$FRAMEWORK_NAME.xcframework/"
mv "$NAME" "$ORIGIN"
cd "$ORIGIN"

# Upload Version in Github
SUM=$(swift package compute-checksum ${NAME} )
BUILD=$(date +%s) 
NEW_VERSION=${VERSION}.${BUILD}
echo $NEW_VERSION > version

DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${NEW_VERSION}/${NAME}"

if [ ! -f $JSON_FILE ]; then
  echo "{}" > $JSON_FILE
fi

# Make Carthage
JSON_CARTHAGE="$(jq --arg version "${NEW_VERSION}" --arg url "${DOWNLOAD_URL}" '. + { ($version): $url }' $JSON_FILE)" 
echo $JSON_CARTHAGE > $JSON_FILE

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

SPM binaryTarget

\`\`\`
.binaryTarget(
  name: "FLEX",
  url: "${URL}",
  checksum: "${SUM}"
)
\`\`\`
END
)

gh release edit ${NEW_VERSION} --notes  "${NOTES}"
echo "${NOTES}"
