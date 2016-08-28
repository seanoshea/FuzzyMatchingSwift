#!/bin/bash

ORGANISATION='Sean O`Shea'
NAME=FuzzyMatchingSwift
BRANCH=develop

if [ "$OUTPUT_PATH" == "" ]; then
    OUTPUT_PATH=docs
fi

GITHUB=https://github.com/seanoshea/FuzzyMatchingSwift

bundle exec jazzy \
  --config .jazzy.json \
  --clean \
  --min-acl private \
  --output "$OUTPUT_PATH" \
  --module-version "$BRANCH" \
  --github_url "$GITHUB" \
  --github-file-prefix "$GITHUB/tree/$BRANCH"
