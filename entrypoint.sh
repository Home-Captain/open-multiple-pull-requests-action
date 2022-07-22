#!/usr/bin/env bash

set -e
set -o pipefail

if [[ -z "$INPUT_GITHUB_TOKEN" ]]; then
  echo "Set the GITHUB_TOKEN environment variable."
  exit 1
fi

if [[ -z "$INPUT_SOURCE_REGEX" ]]; then
  echo "Set the SOURCE_REGEX environment variable."
  exit 1
fi

if [[ -z "$INPUT_DESTINATION_REGEX" ]]; then
  echo "Set the DESTINATION_REGEX environment variable."
  exit 1
fi

echo $INPUT_SOURCE_REGEX
echo $INPUT_DESTINATION_REGEX
echo $GITHUB_REPOSITORY

OUTPUT=$(gh api repos/$GITHUB_REPOSITORY/branches --jq '.[] | select(.name|test("'$INPUT_DESTINATION_REGEX'")) | .name')
echo "${OUTPUT}"

BRANCHES=$(echo $OUTPUT | tr "\s")

for branch in $BRANCHES
do
  echo "Hey this is split:"
  echo $branch
done

for branch in $OUTPUT
do
  echo "This is a branch to merge into:"
  echo $branch
done

IFS='\s' read -ra BR <<< OUTPUT
for branch in "${BR[@]}"; do
  echo "Yet another branch to parse:"
  echo $branch
done

# readarray -t SOURCE_BRANCHES < <("$(gh api repos/$GITHUB_REPOSITORY/branches --jq '.[] | select(.name|test("'$INPUT_DESTINATION_REGEX'")) | .name')")
# echo $SOURCE_BRANCHES

