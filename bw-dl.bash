#!/usr/bin/env bash

cid="$1"

if [ "$2" != "" ] ; then
    downloadDir="$2"/
fi

# This is a JSON which gives us three values that are all required to download
# the images. Requesting it needs a Browser ID which is never checked against
# anything, so for our purposes, it's 0.
auth="$(curl "https://viewer-trial.bookwalker.jp/trial-page/c?cid=$cid&BID=0")"

pfcd="$(echo "$auth" | jq -r .auth_info.pfCd)"
policy="$(echo "$auth" | jq -r .auth_info.Policy)"
signature="$(echo "$auth" | jq -r .auth_info.Signature)"
keyPairId="$(echo "$auth" | jq -r .auth_info.\"Key-Pair-Id\")"

authString='?pfCd='$pfcd'&Policy='$policy'&Signature='$signature'&Key-Pair-Id='$keyPairId

cty="$(echo "$auth" | jq -r .\"cty\")" # whether or not the book is a Manga

baseURL="$(echo "$auth" | jq -r .url)"
if ((cty == 0)) ; then
baseURL="$baseURL"normal_default/
fi

bookName="$(echo "$auth" | jq -r .cti)"

# If the variable is empty, it'll download to ./
bookPath="$downloadDir./$cid"
mkdir -p "$bookPath"

# Download the book's metadata
metadata="$bookPath"/metadata.json

curl "${baseURL}configuration_pack.json$authString" | jq . > "$metadata"

# configuration.contents is an array that contains the chapters with metadata in order
numChapters="$(jq '.configuration.contents | length' "$metadata")"

echo "$bookName" > "$bookPath/name"
echo "$cid" > "$bookPath/cid"
echo "$cty" > "$bookPath/isManga"

# This directory will contain sequentially named links to the pages' actual
# locations under their chapters/
mkdir -p "$bookPath/pages"
# We need to keep track of the page we're at (sequentially)
pageCounter=0

# Truncate the progress file
> "$bookPath/progress"

for chapter in `seq 0 $[numChapters - 1]` ; do
    # Chapter metadata is indexed by its (relative) path
    keyName="$(jq -r ".configuration.contents[$chapter].file" "$metadata")"
    numPages=$(jq -r .\"$keyName\".FileLinkInfo.PageCount "$metadata")

    # "item/xhtml/p-003.xhtml" -> "p-001.xhtml"
    chapterName="$(basename "$keyName")"
    chapterPath="$bookPath"/chapters/"$chapterName"
    mkdir -p "$chapterPath"

    for pageNum in `seq 0 $[numPages - 1]` ; do
        pageCounter=$[pageCounter + 1]

        # The keyName is the path to the page's dir, we can simply put it in the URL
        pageURL="$baseURL$keyName/$pageNum.jpeg$authString"

        # The path the page will be downloaded to
        pagePath="$chapterPath"/"$pageNum".jpg

        # Download the page's image if it doesn't exist already
        if [ -f "$pagePath" ] ; then
            # The page has already been downloaded, mark it as complete
            echo "$pagePath" >> "$bookPath/progress"
        else
            # Download to temp file and then move it to avoid skipping partially
            # downloaded files
            curl $pageURL > "$pagePath".tmp && mv "$pagePath".tmp "$pagePath" && echo "$pagePath" >> "$bookPath/progress"
        fi

        # Create a symlink for every pages/page.jpg to the chapter path it's
        # actually stored under
        if [ ! -f "$bookPath/pages/$pageCounter.jpg" ] ; then
            ln -s --relative "$pagePath" "$bookPath/pages/$pageCounter.jpg"
        fi
    done
done

if [ "$(wc -l < "$bookPath/progress")" == "$pageCounter" ] ; then
    # Delete the progress file, we're done.
    # This file can therefore be used to find uninished downloads
    rm "$bookPath/progress" && exit 0
else
    echo "The number of downloaded pages does not equal the total number of pages, something must've gone wrong!"
    exit 1
fi
