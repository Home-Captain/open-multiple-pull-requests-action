#!/usr/bin/env bash

set -e
set -o pipefail

if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Set the GITHUB_TOKEN environment variable."
  exit 1
fi

if [[ -z "$SOURCE_REGEX" ]]; then
  echo "Set the SOURCE_REGEX environment variable."
  exit 1
fi

if [[ -z "$DESTINATION_REGEX" ]]; then
  echo "Set the DESTINATION_REGEX environment variable."
  exit 1
fi

readarray -t sourceBranches < <("$(gh api repos/{owner}/{repo}/branches --jq '.[] | select(.name|test("'$SOURCE_REGEX'")) | .name'))"

echo $sourceBranches

# citBranches=$(gh api repos/${{ github.repository }}/branches --jq '.[] | select(.name|test("-cit$")) | .name')
# echo 'CIT_BRANCHES='$citBranches >> $GITHUB_ENV

for branch in "${sourceBranches}"
do
  echo $branch
done
