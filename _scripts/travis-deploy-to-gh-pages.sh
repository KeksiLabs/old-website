#!/bin/bash
set -x

# Open the build folder
cd _site

# Create completely new git repo
git init .

# Config git
git config user.name "Travis CI"
git config user.email "travis@keksi.io"

# Add github as remote
git remote add github "https://$GITHB_ACCESS_TOKEN@github.com/$TRAVIS_REPO_SLUG.git"

# and add all files
git add -A

# Commit all files
git commit -am "Builded gh-pages in Travis from master #$TRAVIS_COMMIT"

# Push current master branch as gh-pages into github
git push github master:gh-pages --force

