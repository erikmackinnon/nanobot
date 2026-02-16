#!/usr/bin/env bash
set -euo pipefail

BRANCH="${1:-$(git branch --show-current)}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: run this inside a git repository."
  exit 1
fi

if [[ -z "${BRANCH}" ]]; then
  echo "Error: no current branch detected."
  exit 1
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  echo "Error: missing remote 'origin'."
  exit 1
fi

echo "Pushing ${BRANCH} to origin..."
git push -u origin "${BRANCH}"

echo "Done: ${BRANCH} is on your fork and set to track origin/${BRANCH}."
