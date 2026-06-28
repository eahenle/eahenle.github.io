#!/usr/bin/env bash
set -euo pipefail

PORT="${PORT:-4000}"
HOST="${HOST:-0.0.0.0}"
PAGES_REPO_NWO="${PAGES_REPO_NWO:-eahenle/eahenle.github.io}"
export PAGES_REPO_NWO

cd "$(git rev-parse --show-toplevel)"

if ! command -v bundle >/dev/null 2>&1; then
  echo "Bundler is required to preview this Jekyll site." >&2
  exit 1
fi

if ! bundle check >/dev/null 2>&1; then
  echo "Installing missing bundle dependencies..."
  bundle install
fi

echo "Building Jekyll site with JEKYLL_ENV=production..."
JEKYLL_ENV=production bundle exec jekyll build --trace

echo
printf 'Preview ready: http://localhost:%s/\n' "$PORT"
echo "Serving rendered site through Jekyll on ${HOST}:${PORT}. Keep this process running while reviewing."
echo

exec env JEKYLL_ENV=production bundle exec jekyll serve \
  --host "$HOST" \
  --port "$PORT" \
  --trace \
  --skip-initial-build
