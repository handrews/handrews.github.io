#!/bin/bash

# Author: @ralfhandl, @handrews

thisCommit="$GITHUB_SHA"

# Note that for 3.0, "noDialectSchema" is the only schema
noDialectWIP="schema/WORK-IN-PROGRESS"
vocabWIP="meta/WORK-IN-PROGRESS"
dialectWIP="dialect/WORK-IN-PROGRESS"
strictDialectWIP="schema-base/WORK-IN-PROGRESS"

for schemaDir in schemas/v3* ; do
  version=$(basename "$schemaDir")

  noDialectSchema="$schemaDir/schema.yaml"
  vocabSchema="$schemaDir/meta/base.schema.yaml"
  dialectSchema="$schemaDir/dialect/base.schema.yaml"
  strictDialectSchema="$schemaDir/schema-base.yaml"
  echo $noDialectSchema
  echo $vocabSchema
  echo $dialectSchema
  echo $strictDialectSchema
  echo ""

  if [ -f "$noDialectSchema" ]; then
    noDialectCommit=$(git log -1 --format="%H" -- "$noDialectSchema")
    noDialectCommitDate=$(git log -1 --format="%ad" --date=short -- "$noDialectSchema")
    if [ "$noDialectCommit" = "$thisCommit" ]; then
      updateNoDialect="1"
    fi
  fi

  if [ -f "$vocabSchema" ]; then
    vocabCommit=$(git log -1 --format="%H" -- "$vocabSchema")
    vocabCommitDate=$(git log -1 --format="%ad" --date=short -- "$vocabSchema")
    if [ "$vocabCommit" = "$thisCommit" ]; then
      updateVocab="1"
    fi
  fi

  if [ -f "$dialectSchema" ]; then
    dialectCommit=$(git log -1 --format="%H" -- "$dialectSchema")
    dialectCommitDate=$(git log -1 --format="%ad" --date=short -- "$dialectSchema")
    updateDialect="$updateVocab"
    if [ "$dialectCommit" = "$thisCommit" ]; then
      updateDialect="1"
    fi
  fi

  if [ -f "$strictDialectSchema" ]; then
    strictDialectCommit=$(git log -1 --format="%H" -- "$strictDialectSchema")
    strictDialectCommitDate=$(git log -1 --format="%ad" --date=short -- "$strictDialectSchema")
    updateStrictDialect="$updateDialect"
    if [ -n "$updateNoDialect" ]; then
      updateStrictDialect="1"
    fi
    if [ "$strictDialectCommit" = "$thisCommit" ]; then
      updateStrictDialect="1"
    fi
  fi

  echo $thisCommit
  echo $version $noDialectCommit $noDialectCommitDate $updateNoDialect
  echo $version $vocabCommit $vocabCommitDate $updateVocab
  echo $version $dialectCommit $dialectCommitDate $updateDialect
  echo $version $strictDialectCommit $strictDialectCommitDate $updateStrictDialect
  echo ""

  mkdir -p deploy/oas/$version/schema
  if [ -f "$vocabSchema" ]; then
    mkdir -p deploy/oas/$version/meta/base
    mkdir -p deploy/oas/$version/dialect/base
    if [ -n "$updateNoDialect" ]; then
        node scripts/schema-convert.js "$noDialectSchema" $noDialectCommitDate $vocabCommitDate $dialectCommitDate $strictDialectCommitDate > deploy/oas/$version/schema/$noDialectCommitDate
    fi
    if [ -n "$updateVocab" ]; then
        node scripts/schema-convert.js "$vocabSchema" $noDialectCommitDate $vocabCommitDate $dialectCommitDate $strictDialectCommitDate > deploy/oas/$version/meta/base/$vocabCommitDate
    fi
    if [ -n "$updateDialect" ]; then
        node scripts/schema-convert.js "$dialectSchema" $noDialectCommitDate $vocabCommitDate $dialectCommitDate $strictDialectCommitDate > deploy/oas/$version/dialect/base/$dialectCommitDate
    fi
    if [ -n "$updateStrictDialect" ]; then
        node scripts/schema-convert.js "$strictDialectSchema" $noDialectCommitDate $vocabCommitDate $dialectCommitDate $strictDialectCommitDate > deploy/oas/$version/schema-base/$strictDialectCommitDate
    fi
  else
    if [ -n "$updateNoDialect" ]; then
        node scripts/schema-convert.js "$noDialectSchema" $noDialectCommitDate > deploy/oas/$version/schema/$noDialectCommitDate
    fi
  fi
done

# # run this script from the root of the repo. It is designed to be run by a GitHub workflow.
# for filename in schemas/v3*/schema.yaml ; do
#   vVersion=$(basename $(dirname "$filename"))
#   version=${vVersion:1}
#   lastCommitDate=$(git log -1 --format="%ad" --date=short "$filename")
# 
#   echo "$filename $lastCommitDate"
#   echo "mkdir -p deploy/oas/$version/schema"
#   echo "node scripts/schema-convert.js \"$filename\" $lastCommitDate > deploy/oas/$version/schema/$lastCommitDate"
#   echo "mv deploy/oas/$version/schema/*.md deploy/oas/$version/schema/$lastCommitDate.md"
# 
#   filenameBase="$(dirname "$filename")/schema-base.yaml"
# 
#   if [ -f "$filenameBase" ]; then
#     echo "$filenameBase $lastCommitDate"
#     echo mkdir -p deploy/oas/$version/schema-base
#     echo "node scripts/schema-convert.js \"$filenameBase\" $lastCommitDate > deploy/oas/$version/schema-base/$lastCommitDate"
#     echo mv deploy/oas/$version/schema-base/*.md deploy/oas/$version/schema-base/$lastCommitDate.md
#   fi
# done
