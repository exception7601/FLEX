
FILES=$(find FLEX/Classes/Headers/ -type l -print0 | xargs -0 -I % sh -c '{ echo  "- \"**/$(basename %)\"";}')

echo -n "$FILES"

echo -n "$FILES" | pbcopy

