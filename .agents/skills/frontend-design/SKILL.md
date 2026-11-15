---
name: frontend-design
description: Build web UI (components, pages, dashboards, landing pages, HTML artifacts, posters) with a deliberate visual direction instead of default AI styling. Use when building, styling, or restyling any web interface.
---

# Frontend design

Build working UI with a clear point of view, then look at it before calling it
done.

## Before coding

Write down, in a sentence each:

- Who uses it and what they do on it.
- Constraints: framework, design system, accessibility, performance.
- The visual direction, such as "warm editorial, serif headlines, lots of
  paper" or "dense dark ops console, monospace numbers". Carry that one
  direction through every element.

If the project has a design system, tokens, a Tailwind theme, or a component
library, use it and match the neighbouring screens. The house style below is
for greenfield work and standalone artifacts.

## House style

Oskar's default is quiet and editorial, the same look as the `html-plans`
template:

- Type: a serif display face for headings (Instrument Serif, Newsreader) and a
  readable body face. Fira Code for code. One display face, one body face.
- Color: warm paper and ink. Light `#fbfaf7` background, `#1c1b19` text; dark
  `#181715` background, `#e6e3dc` text; muted `#7a766e`; rules `#dcd8cf`. At
  most one accent. Define them as CSS variables and support
  `prefers-color-scheme`.
- Layout: 60 to 75 characters per line, generous vertical rhythm, left-aligned
  body text, hairline rules instead of boxes and shadows.
- Motion: CSS only for plain HTML, Motion for React. One load reveal at most.
  Respect `prefers-reduced-motion`.

When the brief calls for something else (a game, a brand palette, a dense
tool), commit to that direction just as fully.

## Defaults to avoid

These read as generated:

- Purple, indigo, or purple-to-blue gradients, especially on white.
- Inter, Roboto, or the system stack as the only typeface. Space Grotesk as the
  "distinctive" pick.
- Centered hero, then three icon feature cards, then a CTA band.
- Every surface a rounded card with a drop shadow, or blurred glass panels.
- Emoji as icons or in headings.
- Filler copy: "Supercharge your workflow", "Seamless", "Unlock".

## Build

Ship working code in whatever the project uses. Match effort to the direction:
a minimal design needs precise spacing and type, a maximal one needs the detail
to back it up. Check WCAG AA contrast, visible keyboard focus, and a 390px-wide
layout.

## Verify with screenshots

1. Capture desktop, mobile, and dark mode. Use the harness's browser or preview
   tool if it has one. Otherwise headless Chrome works for files and local dev
   servers:

   ```sh
   chrome="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
   url=file:///abs/path/index.html   # or http://localhost:3000
   "$chrome" --headless --hide-scrollbars --window-size=1440,900 --screenshot=/tmp/ui-desktop.png "$url"
   "$chrome" --headless --hide-scrollbars --window-size=390,844 --screenshot=/tmp/ui-mobile.png "$url"
   "$chrome" --headless --hide-scrollbars --force-dark-mode --window-size=1440,900 --screenshot=/tmp/ui-dark.png "$url"
   ```

2. Open each PNG and check it against the stated direction and the avoid list,
   plus overflow, alignment, contrast, and focus states.
3. Fix what you find and capture again. Report the screenshot paths.
