# Electron desktop project

Requires Node.js 22.18+ or 24.12+ (even-numbered supported releases), npm, and a Linux or Windows desktop.
The template derives from [electron-quick-start](https://github.com/electron/electron-quick-start);
its original [CC0 notice](LICENSE.md) is preserved.

Run `npm ci` to install the pinned dependencies. Starting or packaging the app
downloads the platform-specific Electron runtime when needed. Then use:

- `npm start`, `npm run dev`, or `npm run serve`: run the desktop application.
- `npm run lint`: ESLint checks all application JavaScript without modifying it.
- `npm run build`: build an unpacked desktop application under `dist/` with electron-builder.

The Electron menu offers additional packaging targets. Install packaging prerequisites
for the chosen target and replace the example app ID, product name, author and icons
before distribution. Building the unpacked app does not sign, upload or publish it.

`main.js` creates the window, `preload.js` exposes selected version strings, and
`index.html`/`renderer.js` implement the page. The renderer has no Node integration;
context isolation, the Chromium sandbox and a local-content policy are enabled.
See the [Electron guide](https://www.electronjs.org/docs/latest/tutorial/tutorial-first-app)
and [supported releases](https://releases.electronjs.org/).
