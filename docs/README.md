# Project Documentation Site

This `docs` directory is the source for the project's official documentation website and GitHub Pages deployment.

## GitHub Pages setup

If you are using GitHub Pages:
1. Go to **Settings → Pages**.
2. Set **Build and deployment** source to **Deploy from a branch**.
3. Choose the `main` branch.
4. Set the folder to **/docs**.
5. Save the settings and wait for the site to publish.

## Pages entrypoint

- `index.html` — primary GitHub Pages entrypoint for the live site.
- `Docs.plexcode.html` — compatibility redirect to `index.html`.
- Branding images are loaded from the repository's existing `Assets/Images/` files via GitHub-hosted raw URLs, so no duplicate binary copies are required under `/docs`.

## Other docs content

- `index.md` — markdown landing page/reference content.
- `getting-started.md` — getting-started guide.
- `github-linguist-upstream-custom-language.md` — upstream Linguist contribution guide.
