# Project Documentation Site

This `docs` directory is the source for the project's official documentation website and GitHub Pages deployment.

## GitHub Pages setup

If you are using GitHub Pages:
1. Go to **Settings → Pages**.
2. Set **Build and deployment** source to **Deploy from a branch**.
3. Choose the `main` branch.
4. Set the folder to **/docs**.
5. Save the settings and wait for the site to publish.

## Site structure

- `index.md` — homepage content rendered by Jekyll.
- `_layouts/default.html` — shared docs layout with the sidebar and top navigation.
- `assets/site.css` — dark responsive docs styling.
- `Docs.plexcode.html` — compatibility redirect to the site root.

## Included pages

- `getting-started.md`
- `site-setup.md`
- `github-linguist-upstream-custom-language.md`
- `security.md`
- `legal.md`
