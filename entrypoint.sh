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

readarray -t SOURCE_BRANCHES < <("$(gh api repos/$GITHUB_REPOSITORY/branches --jq '.[] | select(.name|test("'$INPUT_DESTINATION_REGEX'")) | .name')")

echo $SOURCE_BRANCHES

# # citBranches=$(gh api repos/${{ github.repository }}/branches --jq '.[] | select(.name|test("-cit$")) | .name')
# # echo 'CIT_BRANCHES='$citBranches >> $GITHUB_ENV

# for branch in "${sourceBranches}"
# do
#   echo $branch
# done
