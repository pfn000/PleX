# Origin

This page explains the origin and structure of the PlexCode docs site.

## Official source

The official docs source is now the root `/.docs` folder.

## Why this changed

- only one docs folder should exist
- the HTML shell should live next to the markdown content it renders
- the site should be able to publish from `/.docs` without forcing branch-source `/docs` behavior

## Publishing model

GitHub Pages is configured through a custom Actions workflow that uploads the `/.docs` folder as the Pages artifact.
