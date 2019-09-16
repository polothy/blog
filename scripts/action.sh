#!/bin/bash
# Taken from https://github.com/benmatselby/hugo-deploy-gh-pages/blob/master/action.sh

set -e
set -o pipefail

if [[ -n "$TOKEN" ]]; then
	GITHUB_TOKEN=$TOKEN
fi

if [[ -z "$GITHUB_TOKEN" ]]; then
	echo "Set the GITHUB_TOKEN env variable."
	exit 1
fi

if [[ -z "$HUGO_VERSION" ]]; then
    echo 'Set the HUGO_VERSION env variable.'
	  exit 1
fi

echo 'Downloading Hugo'
curl -sSL https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz > /tmp/hugo.tar.gz \
    && tar -f /tmp/hugo.tar.gz -xz

echo 'Cloning the GitHub Pages repo'
rm -fr public
git clone "https://${GITHUB_TOKEN}@github.com/polothy/polothy.github.io.git" public

echo 'Building the Hugo site'
./hugo

echo 'Committing the site to git and pushing'
git config --global user.name "polothy"
git config --global user.email "634657+polothy@users.noreply.github.com"

cd public

if git diff --exit-code > /dev/null 2>&1; then
    echo "There is nothing to commit, so aborting"
    exit 0
fi

git add -A . && \
    git commit -m "Publishing site $(date)" && \
    git push origin master
