#!/usr/bin/env bash

cid="$1"

# This is a JSON which gives us three values that are all required to download
# the images. Requesting it needs a Browser ID which is never checked against
# anything, so for our purposes, it's 0.
auth="$(curl "https://viewer-trial.bookwalker.jp/trial-page/c?cid=$cid&BID=0")"

pfcd="$(echo "$auth" | jq -r .auth_info.pfCd)"
policy="$(echo "$auth" | jq -r .auth_info.Policy)"
signature="$(echo "$auth" | jq -r .auth_info.Signature)"
keyPairId="$(echo "$auth" | jq -r .auth_info.\"Key-Pair-Id\")"

authString='?pfCd='$pfcd'&Policy='$policy'&Signature='$signature'&Key-Pair-Id='$keyPairId

# Download the book's metadata
curl "https://viewer-epubs-trial.bookwalker.jp/special/bw/$cid/SVGA/normal_default/configuration_pack.json$authString" > configuration_pack.json

# configuration.contents is an array that contains the chapters with metadata in order
numChapters="$(jq '.configuration.contents | length' configuration_pack.json)"

for chapter in `seq 0 $[numChapters - 1]` ; do
    # Chapter metadata is indexed by its path
    keyName="$(jq -r ".configuration.contents[$chapter].file" configuration_pack.json)"
    numPages=$(jq -r .\"$keyName\".FileLinkInfo.PageCount configuration_pack.json)

    for page in `seq 0 $[numPages - 1]` ; do
        # The keyName is the patch, we can simply put it in the URL
        echo "https://viewer-epubs-trial.bookwalker.jp/special/bw/$cid/SVGA/normal_default/$keyName/$page.jpeg$authString"
    done
done
