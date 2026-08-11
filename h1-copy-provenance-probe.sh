#!/usr/bin/env bash
set -eu
post_body="$(mktemp)"
get_body="$(mktemp)"
trap 'rm -f "$post_body" "$get_body"' EXIT
printf -v payload '{"ref":"%s","sha":"%s"}' "$H1_CANARY_REF" "$H1_CANARY_TARGET"
post_status="$(curl --silent --show-error --output "$post_body" --write-out '%{http_code}' \
  --request POST \
  --header 'Accept: application/vnd.github+json' \
  --header "Authorization: Bearer $H1_GITHUB_TOKEN" \
  --header 'X-GitHub-Api-Version: 2022-11-28' \
  "https://api.github.com/repos/$H1_REPOSITORY/git/refs" \
  --data "$payload")"
short_ref="${H1_CANARY_REF#refs/}"
get_status="$(curl --silent --show-error --output "$get_body" --write-out '%{http_code}' \
  --request GET \
  --header 'Accept: application/vnd.github+json' \
  --header "Authorization: Bearer $H1_GITHUB_TOKEN" \
  --header 'X-GitHub-Api-Version: 2022-11-28' \
  "https://api.github.com/repos/$H1_REPOSITORY/git/ref/$short_ref")"
printf 'H1_PROVENANCE_SCRIPT_SHA256=%s\n' "$(sha256sum "$0" | awk '{print $1}')"
printf 'H1_PROVENANCE_POST_STATUS=%s\n' "$post_status"
printf 'H1_PROVENANCE_GET_STATUS=%s\n' "$get_status"
