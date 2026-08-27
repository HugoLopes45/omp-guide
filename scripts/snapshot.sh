#!/usr/bin/env sh
# Regenerates data/ from the omp install on PATH.
# An isolated profile keeps the values at pure defaults instead of this machine's config.
set -eu
cd "$(dirname "$0")/.."
mkdir -p data

omp --version | sed 's|^omp/||' > data/version.txt
omp --profile guide-snapshot config list --json | jq -S . > data/settings.json
omp help 2>&1 | sed -n '/^COMMANDS/,/^$/p' > data/subcommands.txt
omp --help 2>&1 | sed -n '/^FLAGS/,/^EXAMPLES/p' > data/flags.txt

echo "snapshot: omp $(cat data/version.txt)"
