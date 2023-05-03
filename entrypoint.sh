#!/usr/bin/env bash

set -x

UPSTREAM_REPO=$1
UPSTREAM_BRANCH=$2
LOCAL_BRANCH=$3
GITHUB_TOKEN=$4
GIT_CLONE_DEPTH=$5
GIT_FETCH_DEPTH_FOR_UPSTREAM=$6

if [[ -z "$UPSTREAM_REPO" ]]; then
  echo "Missing \$UPSTREAM_REPO"
  exit 1
fi

if [[ -z "$UPSTREAM_BRANCH" ]]; then
  echo "Missing \$UPSTREAM_BRANCH"
  exit 1
fi

if [[ -z "$LOCAL_BRANCH" ]]; then
  echo "Missing \$LOCAL_BRANCH"
  exit 1
fi


if ! echo "$UPSTREAM_REPO" | grep '\.git'; then
  UPSTREAM_REPO="https://github.com/${UPSTREAM_REPO_PATH}.git"
fi

echo "UPSTREAM_REPO=$UPSTREAM_REPO"
echo "UPSTREAM_BRANCH=$UPSTREAM_BRANCH"
echo "LOCAL_BRANCH=$LOCAL_BRANCH"
echo "GIT_CLONE_DEPTH=$GIT_CLONE_DEPTH"
echo "GIT_FETCH_DEPTH_FOR_UPSTREAM=$GIT_FETCH_DEPTH_FOR_UPSTREAM"

git clone --depth=$GIT_CLONE_DEPTH "https://github.com/${GITHUB_REPOSITORY}.git" work
cd work || { echo "Missing work dir" && exist 2 ; }

git config user.name "${GITHUB_ACTOR}"
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"
#git remote set-url origin "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

git remote set-url origin "https://$GITHUB_ACTOR:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY"
git remote add upstream "$UPSTREAM_REPO"
git fetch upstream --depth=$GIT_FETCH_DEPTH_FOR_UPSTREAM #$UPSTREAM_BRANCH:$UPSTREAM_BRANCH $UPSTREAM_BRANCH
git remote -v

git checkout $LOCAL_BRANCH

MERGE_RESULT=$(git rebase upstream/$UPSTREAM_BRANCH)
if [[ $MERGE_RESULT != *"up to date"* ]]; then
# git commit -m "Rebase upstream"  
  git push origin $LOCAL_BRANCH -f
fi

cd ..
rm -rf work
