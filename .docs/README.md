# PlexCode Docs Source

This folder is the official docs source for the PlexCode website.

## Contents

- `Docs.PleX.html` — the docs shell / skin
- `Overview.md` — homepage overview content
- `Orign.md` — source and publishing notes
- additional markdown files — automatically shown in the docs sidebar

## Automatic section sync

The website discovers markdown files from this folder through a generated `docs-manifest.json`, so adding a new `.md` file here automatically creates a new section in the sidebar when GitHub Pages rebuilds the site without editing the HTML skin.


## Published manifest

GitHub Pages generates `docs-manifest.json` during deployment so the HTML shell can load the local markdown files directly from the published `/.docs` artifact instead of depending on the GitHub API at runtime.
 
This folder is the official docs source for the PlexCode website.
 

## Contents
 

- `Docs.PleX.html` — the docs shell / skin
- `Overview.md` — homepage overview content
- `Orign.md` — source and publishing notes

The website discovers markdown files from this folder through the GitHub contents API, so adding a new `.md` file here automatically creates a new section in the sidebar without editing the HTML skin.
