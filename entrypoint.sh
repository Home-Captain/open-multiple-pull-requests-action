#!/usr/bin/env bash

set -e
set -o pipefail

if [[ -z "$INPUT_GITHUB_TOKEN" ]]; then
  echo "Set the github_token environment variable."
  exit 1
fi

if [[ -z "$INPUT_SOURCE_REGEX" ]]; then
  echo "Set the input_source_regex environment variable."
  exit 1
fi

if [[ -z "$INPUT_DESTINATION_REGEX" ]]; then
  echo "Set the input_destination_regex environment variable."
  exit 1
fi

echo $INPUT_SOURCE_REGEX
echo $INPUT_DESTINATION_REGEX
echo $GITHUB_REPOSITORY

# Identifies this repo as safe
git config --global --add safe.directory /github/workspace

# Github actions no longer auto set the username and GITHUB_TOKEN
git remote set-url origin "https://x-access-token:$GITHUB_TOKEN@${GITHUB_SERVER_URL#https://}/$GITHUB_REPOSITORY"

# Pull all branches references down locally so subsequent commands can see them
git fetch origin '+refs/heads/*:refs/heads/*' --update-head-ok

INPUT_SOURCES=$(gh api repos/$GITHUB_REPOSITORY/branches --jq '.[] | select(.name|test("'$INPUT_SOURCE_REGEX'")) | .name')
INPUT_DESTINATIONS=$(gh api repos/$GITHUB_REPOSITORY/branches --jq '.[] | select(.name|test("'$INPUT_DESTINATION_REGEX'")) | .name')

echo "${INPUT_SOURCES}"
echo "${INPUT_DESTINATIONS}"

# Returns 0 if branches are the same, 1 if else
diff_branches () {
  # Check if branches are the same
  # $1 source
  # $2 destination
  DIFF="1"
  if [ "$(git rev-parse --revs-only "$1")" = "$(git rev-parse --revs-only "$2")" ];
  then
    echo "Source and destination branches are the same"
    DIFF="0"
  else
    # Do not proceed if there are no file differences, this avoids PRs with just a merge commit and no content
    LINES_CHANGED=$(git diff --name-only "$2" "$1" -- | wc -l | awk '{print $1}')
    if [[ "$LINES_CHANGED" = "0" ]] && [[ ! "$INPUT_PR_ALLOW_EMPTY" ==  "true" ]];
    then
      echo "No file changes detected between source and destination branches"
      DIFF="0"
    fi
  fi
  echo "Readying to merge changes from ${source} to ${destination}..."
}

for destination in $INPUT_DESTINATIONS
do
  for source in $INPUT_SOURCES
  do
    echo "Checking diff between $source and $destination..."
    diff_branches $source $destination
    if [[ "$DIFF" == "1" ]];
    then
      if [ $source == "main" ];
      then
        # Merge changes from main to destination branch
        echo "Merging changes from ${source} to ${destination}..."
        PR=$(gh pr create --base $destination --head $source --title "Merge changes from $source to $destination" --body "Opened by bot")
        echo $PR
      else
        SRC=$(echo $source | sed "s/$INPUT_SOURCE_REGEX//")
        DST=$(echo $destination | sed "s/$INPUT_DESTINATION_REGEX//")
        if [[ $SRC == $DST ]];
        then
          # Merge changes from related source branch to related destination branch
          echo "Merging changes from ${source} to ${destination}..."
          PR=$(gh pr create --base $destination --head $source --title "Merge changes from $source to $destination" --body "Opened by bot")
          echo $PR
        fi
      fi
    fi
  done
done

echo "Success!"
