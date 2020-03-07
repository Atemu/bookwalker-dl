#!/usr/bin/env bash

cid="$1"

# This is a JSON which gives us three values that are all required to download
# the images. Requesting it needs a Browser ID which is never checked against
# anything, so for our purposes, it's 0.
auth="$(curl "https://viewer-trial.bookwalker.jp/trial-page/c?cid=$cid&BID=0")"

pfcd="$(echo "$auth" | jq -r .auth_info.pfCd)"
policy="$(echo "$auth" | jq -r .auth_info.Policy)"
