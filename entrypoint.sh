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
      # gh pr create --head $source --base $destination --title "Merge changes from ${source} to ${destination}"
    else
      SRC=$(echo $source | sed "s/$INPUT_SOURCE_REGEX//")
      DST=$(echo $destination | sed "s/$INPUT_DESTINATION_REGEX//")
      if [[ $SRC == $DST ]];
      then
        # Merge changes from related source branch to related destination branch
        echo "Merging changes from ${source} to ${destination}..."
        echo "gh pr create --base $destination --head $source --fill"
        PR=$(gh pr create --base $destination --head $source --fill)
        echo $PR
      fi
    fi
  done
done