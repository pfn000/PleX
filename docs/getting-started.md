---
layout: default
title: Getting Started
description: Docs workflow and setup
source_path: getting-started.md
permalink: /getting-started.html
---
# Getting started

## Purpose

This docs site is intended to stay synced with GitHub by treating the markdown files in `docs/` as the source of truth.

## How the docs shell works

- each published page is authored in markdown
- the sidebar links keep readers inside the website
- GitHub Pages renders the markdown into the shared docs layout
- `Docs.plexcode.html` remains available as a compatibility redirect to the main site root

## How to add a new docs page

1. Create a new markdown file in `docs/` with front matter.
2. Add a sidebar link for it in `docs/_layouts/default.html`.
- `index.html` is the GitHub Pages entrypoint.
- The left navigation loads markdown pages from the `docs/` folder.
- The main content area renders those markdown files into a docs-style reading layout.
- `Docs.plexcode.html` remains available as a compatibility redirect.

## How to add a new docs page

1. Create a new markdown file in `docs/`.
2. Add the page to the navigation list in `docs/index.html`.
3. Commit the change to `main`.
4. Let GitHub Pages rebuild from the `/docs` folder.

## Good next steps for this repository

- expand installation and setup instructions for PlexCode itself
- add language reference material backed by real `.plxcode` examples
- document package, runtime, and tooling workflows as those parts of the project mature
- document package/runtime/tooling workflows as those parts of the project mature
# Getting Started

## Purpose

This docs site provides official project documentation that can be published through GitHub-hosted documentation tooling.

## Next steps

- Add installation instructions.
- Add configuration and usage guides.
- Add API or architecture docs.

