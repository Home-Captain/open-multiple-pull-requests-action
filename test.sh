#!/usr/bin/env bash

INPUT_SOURCE_REGEX="-cit$"
INPUT_DESTINATION_REGEX="-uat$"

INPUT_SOURCES="test-cit test2-cit"
INPUT_DESTINATIONS="test-uat test2-uat"

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
        # gh pr create --head $source --base $destination --title "Merge changes from ${source} to ${destination}"
      fi
    fi
  done
done