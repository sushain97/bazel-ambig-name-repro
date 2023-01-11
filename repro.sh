#!/usr/bin/env bash
set -euxo pipefail

cd "$(dirname "$0")" || exit

bep_file=$(mktemp)
bazel build //:food --build_event_json_file="$bep_file"

jq < "$bep_file" 'select(.namedSetOfFiles)'
