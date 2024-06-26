#!/bin/bash

# run with DEBUG=1 to enable debugging output
[[ "$DEBUG" = 1 ]] && set -x

IS_XCODE=false
PATH_TO_LINT=
ADDITIONAL_FLAGS='--strict --reporter emoji'
ACTION=lint

while test $# -gt 0; do
    case "$1" in
        --fix)
            ACTION=
            ADDITIONAL_FLAGS=--fix
            shift
            ;;
        -xcode)
            IS_XCODE=true
            ADDITIONAL_FLAGS='--strict --reporter xcode'
            shift
            ;;
        -path)
            PATH_TO_LINT="$2"
            shift 2
            ;;
        *)
            echo "$1 is not a recognized flag!"
            exit 1;
            ;;
    esac
done

# We don't want to lint files in case it is a merge commit.
if [ $(git rev-parse -q --verify MERGE_HEAD) ]; then
    echo "Inside of a merge, abort linting."
    exit 0
fi

if [[ "$IS_XCODE" = true ]]; then
    if [[ "$CI" = true ]]; then
        echo "Skipping SwiftLint from Xcode when running on CI"
        exit 0
    fi
fi

if [[ "$CI" = true ]]; then
    ADDITIONAL_FLAGS='--strict'
fi

if [[ "$GITHUB_ACTIONS" = true ]]; then
    ADDITIONAL_FLAGS='--strict --reporter github-actions-logging'
fi

if [ ! -f "$PATH_TO_LINT/Mintfile" ]; then
    echo "error: Mintfile not found"
    exit 1
fi

if [ ! -f "$PATH_TO_LINT/.swiftlint.yml" ]; then
    echo "error: file .swiftlint.yml not found"
    exit 1
fi

# We use Mint to run SwiftLint. If the specified version of SwiftLint is not available, it will be installed and then run by this command.
# We need to provide whole path to mint because SourceTree does not have the same $PATH as a regular bash environment.
SWIFT_LINT='/usr/local/bin/mint run -s realm/SwiftLint swiftlint'

count=0

# Change IFS variable to \n so that we could properly iterate through the files with spaces in their names. https://bash.cyberciti.biz/guide/$IFS
IFS=$(echo -en "\n\b")
if [[ -n "$PATH_TO_LINT" ]]; then
  # Collect all *.swift files in the desired folder to lint. (This is necessary because SwiftLint does not support nested configurations when exact path is passed)
  files_to_lint=$(find "$PATH_TO_LINT" -type f -name "*.swift" -not -path "*/Pods/*" -not -path "*/vendor/*")
else
  # Check for modified files except of the removed ones (SwiftLint crashes in case it processes a path to a file that was removed)
  files_to_lint=$(git --no-pager diff HEAD --staged --name-only --diff-filter=d | grep -v Pods | grep ".swift$")
  if [[ -n "$files_to_lint" ]]; then
    echo -n "Found files with changes."
  fi
fi
for file_path in $files_to_lint; do
    export SCRIPT_INPUT_FILE_$count=$file_path
    count=$((count + 1))
done
# Make the count available as global variable
export SCRIPT_INPUT_FILE_COUNT=$count

# Lint files or exit if no files found for linting #####
RESULT=
if [ "$count" -ne 0 ]; then
    echo "Linting..."

    eval $SWIFT_LINT $ACTION --use-script-input-files --quiet $ADDITIONAL_FLAGS
    RESULT=$?
else
    echo "No files to lint!"
    exit 0
fi

echo "SwiftLint exit result number: ${RESULT}"

if [ $RESULT -eq 2 ]; then
    echo "Serious violations are found!"
elif [ $RESULT -eq 3 ]; then
    echo "Strict warnings are found!"
else
    echo "Success! No serious violations!"
fi

if [[ "$IS_XCODE" = true && "$CI" != true ]]; then
    exit 0 # We always exit successfully so that we wouldn't be blocked by some of the files not passing the linter.
else
    exit $RESULT
fi
