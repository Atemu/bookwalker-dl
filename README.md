This tool helps you make private copies of bookwalker books that are available publicly under the `viewer-trial` subdomain.  
It might work for other books too but that's not my goal here and probably doesn't work (it might with a few cookies and tweaks though).

The tool takes a cid (the UUID-like strings in the bookwalker URLs) and an optional download location as arguments and downloads every page of the book in order.
The default download directory is `./$cid/` and you can make it relative to a different path by setting the second argument.

In this directory the tool creates:

* `cid`: A text file containing the cid
* `name`: A text file containing actual name of the book
* `metadata.json`: Metadata about chapters and pages (mostly used internally but also contains things like page- and chapter names)
* `chapters/`: A directory with all chapters as sub-directories that contain the individual pages' images
* `pages/`: A directory with sequentially named symlinks to the chapters' pages

Dependencies are listed in `shell.nix`, they should be pretty clear even if you don't use Nix.

# License

This project is licensed under the GPLv2 or, at your choice, any later version released by the Free Software Foundation.
