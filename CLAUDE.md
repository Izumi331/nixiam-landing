# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Static marketing site for Nixiam (backup/restore services for SMBs — Microsoft 365, Google Workspace, servers, workstations). Plain HTML/CSS/JS, no build tooling, no package manager, no framework. Content and copy are in French.

## Running locally

There's no build step. Two ways to preview:

- Build and run the Docker image (matches production serving behavior, including SSI includes):
  ```
  docker build -t nixiam-landing .
  docker run --rm -p 8080:80 nixiam-landing
  ```
- Or serve the directory with any static server that supports SSI if you need header/footer includes to resolve; opening the HTML files directly in a browser will NOT render the `<!--#include virtual="..." -->` directives.

There is no lint/test/build command — this is hand-written static HTML.

## Deployment architecture

`Dockerfile` builds an `nginx:alpine` image: `default.conf` enables SSI (`ssi on;`) and serves everything from `/usr/share/nginx/html`. `nixiam-landing.html` is copied in as `index.html`. 404s route to `404.html`.

## Page structure — two different patterns in this repo

- **Sub-pages** (`mentions-legales.html`, `politique-confidentialite.html`, `404.html`) pull in the shared chrome via nginx SSI:
  ```
  <!--#include virtual="/header.html" -->
  ...
  <!--#include virtual="/footer.html" -->
  ```
  `header.html` and `footer.html` contain their own `<style>` blocks and are self-contained partials — edit them once and every page that includes them updates.
- **The homepage** (`nixiam-landing.html`) does **not** use the shared includes. It has its own inline hero/nav markup and its own inline `<footer>`, styled by its own `<style>` block in `<head>`. If you change the shared nav/footer (colors, links, logo), you must also update `nixiam-landing.html` separately or it will drift out of sync.

Each page/partial duplicates the same CSS custom-property palette (`--violet`, `--indigo`, `--lavande`, `--vert-fonce`, etc.) in its own `<style>` block rather than sharing a stylesheet — there is no shared CSS file, so palette or type changes must be applied per-file.

`header.html`'s nav links to `/offre-essentiel.html`, `/offre-business.html`, `/comment-ca-marche.html`, and `/tarifs.html` — none of these pages exist yet in the repo. Don't assume they're present.

## Lead capture form

`nixiam-landing.html` contains a lead form that POSTs JSON to an external API defined near the top of its `<script>` block:

```js
const API_URL = "https://leads.nixiam.fr/api/leads";
```

- The admin view (`?admin=1` query param) prompts for a key and GETs `${API_URL}?key=...` to render submitted leads in a table injected into the page.
- This site has no backend of its own; the lead API is a separate service and out of scope for this repo.
