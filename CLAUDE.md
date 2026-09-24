# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Static marketing site for Nixiam (backup/restore services for SMBs). The offer is deliberately limited to **workstations (Essentiel)** and **Microsoft 365 / Google Workspace (Business)** — no server backup; don't reintroduce "serveurs" in copy. Plain HTML/CSS/JS, no build tooling, no package manager, no framework. Content and copy are in French.

## Running locally

There's no build step. Build and run the Docker image (matches production serving behavior, including SSI includes):
```
docker build -t nixiam-landing .
docker run --rm -p 8080:80 nixiam-landing
```
Opening the HTML files directly in a browser will NOT render the `<!--#include virtual="..." -->` directives.

There is no lint/test/build command — this is hand-written static HTML.

## Deployment

- `Dockerfile` builds an `nginx:alpine` image and copies **each file explicitly** — a new page must be added to the `Dockerfile` (and to `sitemap.xml`) or it won't be served.
- `nixiam-landing.html` is copied in as `index.html` (served at `/`).
- `default.conf` enables SSI (`ssi on;`), routes 404s to `404.html`, and marks the partials (`header.html`, `footer.html`, `calc-widget.html`) `internal` so they only resolve through SSI includes, not by direct URL.
- Production runs on this host as the container `nixiam-landing` (`--restart unless-stopped -p 8080:80`). Before replacing it, test the new image on a separate container/port.

## Pages

Public pages: `nixiam-landing.html` (home), `offre-essentiel.html`, `offre-business.html`, `tarifs.html`, `calculateur.html`, `comment-ca-marche.html`, `faq.html`, `contact.html`, `mentions-legales.html`, `politique-confidentialite.html`, plus `404.html` (noindex).

**Every page, including the homepage**, pulls the shared chrome via SSI:
```
<!--#include virtual="/header.html" -->
...
<!--#include virtual="/footer.html" -->
```
- `header.html` / `footer.html` are self-contained partials with their own `<style>` blocks. Nav and footer links live only there.
- `footer.html` itself includes `calc-widget.html`, so the floating price calculator ("Estimer mon prix" button + slide-in panel with lead capture) is on every page. It hides its own button on `/calculateur.html`. Any link with `data-open-calc="essentiel|business"` (or empty) opens the panel instead of navigating; give such links `href="/calculateur.html"` as a no-JS fallback.

There is no shared stylesheet: each page duplicates the CSS custom-property palette (`--violet`, `--indigo`, `--lavande`, `--vert-fonce`, etc.) and its component styles in its own `<style>` block, so palette/type changes must be applied per file.

Each public page's `<head>` carries: unique `<title>` and meta description, `<link rel="canonical">` with its exact `https://nixiam.fr/...` URL, and Open Graph/Twitter tags including `og:site_name`. The home page has an `Organization` JSON-LD (`@id` `https://nixiam.fr/#org`); both offer pages have a `Service` JSON-LD referencing it — keep their price ranges in sync with the grids.

`faq.html` has a `FAQPage` JSON-LD in its `<head>` that must match the visible Q&A **word for word** (Google penalizes a mismatch). Whenever a `<details class="faq-item">` is added, removed, reordered or reworded, regenerate the whole JSON-LD block from the page markup — take each `<summary>` text as `name` and its `<p>` text (plain text, no HTML, whitespace collapsed) as `acceptedAnswer.text` — rather than editing it by hand. Then check that the JSON parses and that the entry count and texts match the visible `<details>`.

## Pricing — duplicated in several places

The price grids and setup-fee formulas are hardcoded in **five** places that must stay consistent: `offre-essentiel.html`, `offre-business.html`, `tarifs.html`, `calculateur.html` (JS `ESSENTIEL` / `BUSINESS` / `setup*`), and `calc-widget.html` (same JS, duplicated), plus the JSON-LD price ranges on the offer pages. Beyond 50 postes / 50 users (monthly price and setup fee) is "sur devis" everywhere.

## Lead capture

Both `contact.html` (full form) and `calc-widget.html` (entreprise + email) POST JSON to:
```js
const API_URL = "https://leads.nixiam.fr/api/leads";
```
- The API is a separate service (source in `/opt/nixiam-leads/server.js`, out of scope for this repo). It **whitelists** fields: `entreprise`, `taille`, `secteur`, `solution`, `regle321`, `email`; `website` is the honeypot. Any other field is silently dropped — a new form field needs a matching change in the API to be stored.
- `contact.html` pre-fills hidden fields from the query string: `?regle321=...` (from the home-page 3-2-1 quiz) and `?offre=essentiel|business` (from offer pages / calculator links).
- The home page admin view (`/?admin=1`) prompts for a key and GETs `${API_URL}?key=...` to render submitted leads in a table.
- `politique-confidentialite.html` lists the collected fields — update it when the forms change.
