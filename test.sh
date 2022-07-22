#!/usr/bin/env bash

INPUT_SOURCE_REGEX="main"
INPUT_DESTINATION_REGEX="-cit$"

INPUT_SOURCES="main"
INPUT_DESTINATIONS="test-cit test2-cit"

# INPUT_SOURCE_REGEX="-cit$"
# INPUT_DESTINATION_REGEX="-uat$"

# INPUT_SOURCES="test-cit test2-cit"
# INPUT_DESTINATIONS="test-uat test2-uat"

echo "${INPUT_SOURCES}"
echo "${INPUT_DESTINATIONS}"

# Returns 0 if branches are the same, 1 if else
diff_branches () {
  DIFF="1"
  return 1
  # # Check if branches are the same
  # # $1 source
  # # $2 destination
  # if [ "$(git rev-parse --revs-only "$1")" = "$(git rev-parse --revs-only "$2")" ];
  # then
  #   echo "Source and destination branches are the same"
  #   DIFF="0"
  # else
  #   # Do not proceed if there are no file differences, this avoids PRs with just a merge commit and no content
  #   LINES_CHANGED=$(git diff --name-only "$2" "$1" -- | wc -l | awk '{print $1}')
  #   if [[ "$LINES_CHANGED" = "0" ]] && [[ ! "$INPUT_PR_ALLOW_EMPTY" ==  "true" ]];
  #   then
  #     echo "No file changes detected between source and destination branches."
  #     DIFF="0"
  #     return 0
  #   fi
  # fi
  # echo "Readying to merge changes from ${source} to ${destination}..."
  # DIFF="1"
}

for destination in $INPUT_DESTINATIONS
do
  for source in $INPUT_SOURCES
  do
    diff_branches $source $destination
    echo $DIFF
    if [[ $DIFF -eq "1" ]];
    then
      if [ $source == "main" ];
      then
        # Merge changes from main to destination branch
        echo "Merging changes from ${source} to ${destination}..."
        # PR=$(gh pr create --base $destination --head $source --title "Merge changes from $source to $destination" --body "Opened by bot")
        # echo $PR
      else
        SRC=$(echo $source | sed "s/$INPUT_SOURCE_REGEX//")
        DST=$(echo $destination | sed "s/$INPUT_DESTINATION_REGEX//")
        if [[ $SRC == $DST ]];
        then
          # Merge changes from related source branch to related destination branch
          echo "Merging changes from ${source} to ${destination}..."
          # PR=$(gh pr create --base $destination --head $source --title "Merge changes from $source to $destination" --body "Opened by bot")
          # echo $PR
        fi
      fi
    fi
  done
done