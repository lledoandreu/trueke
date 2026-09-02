#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

echo "==> dart format"
dart format --output=none --set-exit-if-changed lib test

echo "==> flutter analyze"
flutter analyze

echo "==> flutter test"
flutter test

if command -v supabase >/dev/null 2>&1; then
  if supabase status >/dev/null 2>&1; then
    echo "==> supabase db reset --local --no-seed"
    supabase db reset --local --no-seed

    echo "==> supabase migration list --local"
    supabase migration list --local

    echo "==> supabase test db"
    supabase test db
  else
    echo "==> supabase CLI found, local stack not running (skip db checks)"
  fi
else
  echo "==> supabase CLI not found (skip db checks)"
fi

echo "==> verify OK"
