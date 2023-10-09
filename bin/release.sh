#!/usr/bin/env bash

set -eou pipefail

# Smoke tests
mix format --check-formatted
mix credo
mix test
grep -q "$VERSION" CHANGELOG.md || (echo "Make sure that the release notes are up to date" && false)

VERSION=$1
sed -i "s/@version .*/@version \"$VERSION\"/g" mix.exs
sed -i "s/{:saxaboom, .*/{:saxaboom, \"$VERSION\"}/g" README.md
git add mix.exs
git commit -m "Releasing ${VERSION}"
git tag v$VERSION
git push --tags
mix hex.publish
