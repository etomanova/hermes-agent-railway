#!/usr/bin/env bash
set -e

AUTO_UPDATE="${AUTO_UPDATE:-false}"

if [ "$AUTO_UPDATE" = "true" ]; then
  echo "Checking for Hermes updates..."
  cd /opt/hermes-agent
  if git pull --recurse-submodules 2>&1 | grep -v 'Already up to date'; then
    echo "Updating dependencies..."
    VIRTUAL_ENV=/opt/hermes-agent/venv uv pip install -e ".[all]" --quiet
    echo "Update complete."
  else
    echo "Already up to date."
  fi
fi

# npm deps were installed during the Docker build phase (web/node_modules already exists).
# Setting HERMES_SKIP_NPM_INSTALL=1 prevents the dashboard command from attempting a
# redundant `npm install` at container startup, which fails in the Railway runtime.
export HERMES_SKIP_NPM_INSTALL=1
hermes dashboard --host 127.0.0.1 --port 9119 --no-open &

exec python /auth_proxy.py
