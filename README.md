This tool is supposed to help you make a private copy of bookwalker books that are available publicly under their `viewer-trial` subdomain.  
It might work for others too with a few cookies and tweaks but that's not my goal here.

This is very much a WIP but currently it takes a cid (Content ID, the UUID-like string in the bw URLs), fetches auth tokens and uses them to download a book's metadata. This metadata file holds information about the chapters (each key is a chapter).  
The individual images of a chapter are available under `$chapterName/$page.jpeg$authTokenString`.
