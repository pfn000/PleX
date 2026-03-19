# Getting Started

## Purpose

Use this section to explain installation, setup, and first-run guidance for PlexCode.

## Docs workflow

1. Add a markdown file to `/.docs`.
2. Commit it to GitHub.
3. GitHub Pages republishes the site from the workflow.
4. The HTML shell discovers the new markdown file automatically.
# GitHub Linguist Guide

PlexCode-specific file types are currently managed locally while the project prepares an upstream GitHub Linguist contribution.

## Current local handling

- `.plxcode` is force-detected for repository language stats
- custom metadata files can be marked vendored to avoid polluting the language bar

## Long-term plan

The goal is to contribute a real PleX/PlexCode language definition upstream to GitHub Linguist so the repo can stop relying on temporary remaps.
