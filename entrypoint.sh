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

SAFE=$(git config --global --add safe.directory /github/workspace)
echo $SAFE

INPUT_SOURCES=$(gh api repos/$GITHUB_REPOSITORY/branches --jq '.[] | select(.name|test("'$INPUT_SOURCE_REGEX'")) | .name')
INPUT_DESTINATIONS=$(gh api repos/$GITHUB_REPOSITORY/branches --jq '.[] | select(.name|test("'$INPUT_DESTINATION_REGEX'")) | .name')

echo "${INPUT_SOURCES}"
echo "${INPUT_DESTINATIONS}"

# gh pr create --base $line --head main; done

for destination in $INPUT_DESTINATIONS
do
  for source in $INPUT_SOURCES
  do
    if [ $source == "main" ];
    then # Merge changes from main to destination branch
      echo "Merging changes from ${source} to ${destination}..."
      echo "gh pr create --base $destination --head $source --fill"
      PR=$(gh pr create --base $destination --head $source --fill)
      echo $PR
    else
      SRC=$(echo $source | sed "s/$INPUT_SOURCE_REGEX//")
      DST=$(echo $destination | sed "s/$INPUT_DESTINATION_REGEX//")
      if [[ $SRC == $DST ]];
      then
        # Check if branches are the same
        if [ "$(git rev-parse --revs-only "$source")" = "$(git rev-parse --revs-only "$destination")" ];
        then
          echo "Source and destination branches are the same"
        else
          # Do not proceed if there are no file differences, this avoids PRs with just a merge commit and no content
          LINES_CHANGED=$(git diff --name-only "$destination" "$source" -- | wc -l | awk '{print $1}')
          if [[ "$LINES_CHANGED" = "0" ]] && [[ ! "$INPUT_PR_ALLOW_EMPTY" ==  "true" ]];
          then
            echo "No file changes detected between source and destination branches."
          else
            # Merge changes from related source branch to related destination branch
            echo "Merging changes from ${source} to ${destination}..."
            echo "gh pr create --base $destination --head $source --fill"
            PR=$(gh pr create --base $destination --head $source --fill)
            echo $PR
          fi
        fi
      fi
    fi
  done
done