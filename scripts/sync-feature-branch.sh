#!/usr/bin/env bash
set -euo pipefail

FEATURE_BRANCH="${1:-$(git branch --show-current)}"
MAIN_BRANCH="${2:-main}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: run this inside a git repository."
  exit 1
fi

if [[ -z "${FEATURE_BRANCH}" ]]; then
  echo "Error: no feature branch detected."
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

if [[ "${FEATURE_BRANCH}" == "${MAIN_BRANCH}" ]]; then
  echo "Error: feature branch and main branch are the same (${MAIN_BRANCH})."
  echo "Use ./scripts/sync-upstream-main.sh instead."
  exit 1
fi

START_BRANCH="$(git branch --show-current)"

echo "Fetching upstream..."
git fetch upstream

echo "Syncing ${MAIN_BRANCH} from upstream/${MAIN_BRANCH}..."
git switch "${MAIN_BRANCH}"
git merge --ff-only "upstream/${MAIN_BRANCH}"
git push origin "${MAIN_BRANCH}"

echo "Rebasing ${FEATURE_BRANCH} onto ${MAIN_BRANCH}..."
git switch "${FEATURE_BRANCH}"
git rebase "${MAIN_BRANCH}"

echo "Pushing rebased ${FEATURE_BRANCH} to origin..."
git push --force-with-lease origin "${FEATURE_BRANCH}"

if [[ "${START_BRANCH}" != "${FEATURE_BRANCH}" ]]; then
  git switch "${START_BRANCH}"
fi

echo "Done: ${FEATURE_BRANCH} rebased on ${MAIN_BRANCH} and pushed to origin."
