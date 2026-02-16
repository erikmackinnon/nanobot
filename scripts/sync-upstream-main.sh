#!/usr/bin/env bash
set -euo pipefail

TARGET_BRANCH="${1:-main}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: run this inside a git repository."
  exit 1
fi

if ! git remote get-url upstream >/dev/null 2>&1; then
  echo "Error: missing remote 'upstream'."
  exit 1
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  echo "Error: missing remote 'origin'."
  exit 1
fi

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Error: working tree is not clean. Commit or stash before syncing."
  exit 1
fi

CURRENT_BRANCH="$(git branch --show-current)"

echo "Fetching upstream..."
git fetch upstream

echo "Updating local ${TARGET_BRANCH} from upstream/${TARGET_BRANCH}..."
git switch "${TARGET_BRANCH}"
git merge --ff-only "upstream/${TARGET_BRANCH}"

echo "Pushing ${TARGET_BRANCH} to origin..."
git push origin "${TARGET_BRANCH}"

if [[ "${CURRENT_BRANCH}" != "${TARGET_BRANCH}" ]]; then
  git switch "${CURRENT_BRANCH}"
fi

echo "Done: ${TARGET_BRANCH} is synced from upstream and pushed to origin."
