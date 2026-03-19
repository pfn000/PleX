---
layout: default
title: Site Setup
description: GitHub Pages + docs folder
source_path: site-setup.md
permalink: /site-setup.html
---

## GitHub Pages setup

If you are using GitHub Pages:

1. Go to **Settings → Pages**.
2. Set **Build and deployment** source to **Deploy from a branch**.
3. Choose the `main` branch.
4. Set the folder to **/docs**.
5. Save the settings and wait for the site to publish.

## Pages entrypoint

- `index.md` is the homepage for the rendered docs site.
- `Docs.plexcode.html` is a compatibility redirect to the site root.
- `_layouts/default.html` provides the shared docs chrome and sidebar.
- `assets/site.css` provides the dark responsive styling.

## Why the docs live here

Keeping the publishable docs inside `docs/` lets GitHub Pages serve the site directly from the repository while keeping the markdown source visible and editable in GitHub.
