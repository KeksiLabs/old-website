#!/bin/bash

# Open the build folder
cd _site

# Create completely new git repo
git init .

# Config git
git config user.name "Keksi Labs Bot"
git config user.email "bot@keksi.io"

# Add CNAME for the site
if [ "$SITE_DOMAIN" != "" ]; then
    echo $SITE_DOMAIN > CNAME
fi

# Add github as remote
git remote add github "https://$GITHUB_ACCESS_TOKEN@github.com/$TRAVIS_REPO_SLUG.git" --quiet

# and add all files
git add -A

# Commit all files
git commit -am "Builded gh-pages from master in Travis\nCommit-ID:$TRAVIS_COMMIT"

# Push current master branch as gh-pages into github
# Don't output anything so that $GITHUB_ACCESS_TOKEN won't go into the logs
echo "Pushing to https://github.com/$TRAVIS_REPO_SLUG quietly"
git push github master:gh-pages --force --quiet

