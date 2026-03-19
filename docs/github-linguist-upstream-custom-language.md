---
layout: default
title: GitHub Linguist Guide
description: Upstream contribution checklist
source_path: github-linguist-upstream-custom-language.md
permalink: /github-linguist-upstream-custom-language.html
---

# Contributing PleX file types to GitHub Linguist

This guide is a project-specific checklist for contributing a real custom language definition upstream to [`github-linguist/linguist`](https://github.com/github-linguist/linguist).

## What GitHub Linguist can and cannot do

- `/.gitattributes` can remap files to an existing language or exclude them from language statistics.
- `/.gitattributes` cannot create a brand-new language name in GitHub's language bar.
- To get a real custom language name, extensions, syntax grammar, and an official language-bar color, the language must be added upstream to GitHub Linguist.

## What to upstream for PleX

If you want GitHub to recognize these as a real PleX-family language instead of showing JavaScript/Python/etc., the upstream contribution should define one language entry and then associate the relevant extensions with it.

Suggested initial scope:

- Language name: `PleX`
- Primary extension: `.plxcode`
- Additional extensions to consider: `.plx`, `.Khon`, `.TAG`
- Special filename to consider separately: `.Attributes`
- Proposed color: `#00F58C`

> Note: you should only include extensions/filenames that have enough real-world public usage to satisfy Linguist's contribution rules.

## Upstream contribution checklist

### 1. Confirm the language is eligible

GitHub Linguist requires evidence of real-world usage on public GitHub repositories before accepting a new language or extension.

For each extension or filename you want to add, gather GitHub code search links that show public usage excluding forks.

Suggested searches to prepare:

- `path:*.plxcode fork:false`
- `path:*.plx fork:false`
- `path:*.Khon fork:false`
- `path:*.TAG fork:false`
- `filename:.Attributes fork:false`

Keep notes on:

- approximate result counts
- which repos are returned
- whether the results are distributed across multiple owners
- whether any one account dominates the results

### 2. Decide whether this is one language or multiple languages

Before opening a PR upstream, decide whether all of these file types really belong to one language:

- `.plxcode`
- `.plx`
- `.Khon`
- `.TAG`
- `.Attributes`

If some of these are metadata or manifest files rather than source code, do **not** include them as language extensions. For example:

- `.Attributes` may be better treated as metadata, not source code.
- `.TAG` may be better treated as a tag/config artifact, not source code.

A cleaner upstream PR usually has a better chance of review.

### 3. Prepare a syntax-highlighting grammar

Linguist expects a TextMate-compatible grammar for syntax highlighting.

You will need either:

- an existing grammar repository for PleX, or
- a new grammar repository that defines the language scopes and highlighting rules

The grammar license must be acceptable to Linguist.

### 4. Prepare representative samples

Linguist maintainers prefer real-world samples instead of tutorial-style snippets.

Prepare:

- at least one representative `.plxcode` sample
- additional representative samples for any extra extension you want accepted
- source/license information for every sample

Avoid `hello world`-style examples.

### 5. Open an upstream PR against `github-linguist/linguist`

Based on Linguist's contribution guide, the upstream PR will usually need to:

1. add a new language entry to `languages.yml`
2. add the grammar with `script/add-grammar <grammar-repo-url>`
3. add samples under the correct `samples/` directory
4. run `script/update-ids`
5. include GitHub search evidence and licensing details in the PR template

## Suggested upstream language entry

A future upstream PR will need to be adjusted to match the official Linguist schema and your final extension decisions, but the rough shape would look like this:

```yaml
PleX:
  type: programming
  color: "#00F58C"
  extensions:
    - ".plxcode"
```

Add extra extensions only if they truly represent source code for the same language and have enough public usage.

## Recommended contribution strategy

Start small.

Recommended order:

1. contribute `PleX` with only `.plxcode`
2. get the language accepted upstream
3. add more extensions later only if the evidence is strong
4. keep metadata files such as `.Attributes` out of the language definition unless they are actually source code

This reduces review friction and lowers the risk of misclassification.

## What to keep in this repo while the upstream PR is pending

Until GitHub Linguist accepts the new language:

- keep `*.plxcode linguist-language=Sway` if you want the files counted today
- keep custom metadata files vendored if you do **not** want them polluting the language bar
- remove temporary remaps once the upstream language ships on GitHub

## Upstream PR prep checklist

Before you open the upstream PR, make sure you have all of the following:

- [ ] a grammar repository URL
- [ ] public usage evidence for each proposed extension/filename
- [ ] sample files with clear license/source provenance
- [ ] a proposed color and justification
- [ ] confirmation that the files are source code rather than metadata
- [ ] a narrow initial scope, ideally `.plxcode` first

## Tracking checklist for this repository

Use this list to prepare the upstream contribution from this repo:

- [ ] collect real `.plxcode` examples
- [ ] decide whether `.plx` is source code or vendor/archive content
- [ ] decide whether `.Khon` is source code or a secondary artifact
- [ ] keep `.TAG` and `.Attributes` out of the language proposal unless they are executable/source files
- [ ] create or identify a TextMate-compatible PleX grammar repo
- [ ] draft the `github-linguist/linguist` PR
