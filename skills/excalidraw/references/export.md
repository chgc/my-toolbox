# Export to PNG/SVG

Export `.excalidraw` files to PNG and/or SVG.

Two approaches are available:
- **Node.js CLI (recommended)** — fully offline, no browser, no server required
- **Playwright/Browser** — online via CDN or offline via local server

---

## Method 1: Node.js CLI (Recommended)

No browser, no Python server, no CDN. Runs entirely in Node.js with prebuilt binaries.

### One-Time Setup

```powershell
cd .claude/skills/excalidraw/lib
npm install
```

This installs `@excalidraw/utils`, `jsdom`, and `@resvg/resvg-js` (~95 MB in `node_modules/`; fonts included).

### Export SVG

```powershell
node .claude/skills/excalidraw/lib/export.cjs path/to/diagram.excalidraw path/to/output.svg
```

### Export PNG

```powershell
node .claude/skills/excalidraw/lib/export.cjs path/to/diagram.excalidraw path/to/output.png
```

Output format is determined by file extension. Both commands are fully offline after `npm install`.

### How It Works

1. `jsdom` provides browser globals so `@excalidraw/utils` runs in Node.js
2. `exportToSvg()` generates an SVG string with embedded fonts
3. For PNG: `@resvg/resvg-js` (Rust-based, prebuilt Windows binaries) renders the SVG using bundled `.ttf` font files from `node_modules/@excalidraw/utils/dist/prod/assets/`

---

## Method 2: Playwright/Browser

### Prerequisites

- Playwright MCP tools available: `browser_navigate`, `browser_run_code`, `browser_close`
- Python 3 installed (for local HTTP server)

## Method 2 Procedure

### 1. Start a Local HTTP Server

A browser origin is required for dynamic ESM imports. Start a temporary server on any available port:

```bash
python3 -m http.server 8765 &
SERVER_PID=$!
```

### 2. Navigate Playwright to the Server

```
browser_navigate → http://localhost:8765/
```

The 404 page is fine — we only need the HTTP origin for the dynamic import to work.

### 3. Read the .excalidraw File

Use the Read tool to get the `.excalidraw` file contents as a string. This JSON string will be passed into the browser context in the next steps.

### 4. Export SVG

Use `browser_run_code` with the following pattern. Replace `EXCALIDRAW_JSON_HERE` with the actual JSON string from Step 3:

```javascript
async (page) => {
  const excalidrawJson = `EXCALIDRAW_JSON_HERE`;

  const svgString = await page.evaluate(async (json) => {
    const { exportToSvg } = await import('https://esm.sh/@excalidraw/utils@0.1.3-test32');
    const data = JSON.parse(json);
    const svg = await exportToSvg({
      elements: data.elements,
      appState: { ...data.appState, exportBackground: true },
      files: data.files || {}
    });
    return svg.outerHTML;
  }, excalidrawJson);

  return svgString;
}
```

Write the returned SVG string directly to `<filename>.svg` using the Write tool.

### 5. Export PNG

Use `browser_run_code` with the following pattern:

```javascript
async (page) => {
  const excalidrawJson = `EXCALIDRAW_JSON_HERE`;

  const pngBase64 = await page.evaluate(async (json) => {
    const { exportToBlob } = await import('https://esm.sh/@excalidraw/utils@0.1.3-test32');
    const data = JSON.parse(json);
    const blob = await exportToBlob({
      elements: data.elements,
      appState: { ...data.appState, exportBackground: true },
      files: data.files || {},
      mimeType: 'image/png'
    });
    const reader = new FileReader();
    return new Promise((resolve) => {
      reader.onloadend = () => resolve(reader.result);
      reader.readAsDataURL(blob);
    });
  }, excalidrawJson);

  return pngBase64;
}
```

The result is a base64 data URL. Decode and write to `<filename>.png`:

```bash
echo "<base64_data_without_prefix>" | base64 -d > <filename>.png
```

Strip the `data:image/png;base64,` prefix before decoding.

### 6. Clean Up

Close the browser and kill the HTTP server:

```
browser_close
```

```bash
kill $SERVER_PID
```

## Key Details

- **Import path**: Use `@excalidraw/utils@0.1.3-test32` — this is the correct version with embedded fonts. Export functions are named exports (e.g., `const { exportToBlob } = await import('https://esm.sh/@excalidraw/utils@0.1.3-test32')`).
- **⚠️ Do NOT use `@0.1.2`**: That version produces `y="NaN"` for all text elements, making all text invisible in every export.
- **Fonts**: v0.1.3-test32 embeds Virgil font as a base64 data URL — no external font loading required.
- **Console errors**: `<text> attribute y: Expected length` warnings are cosmetic — exports are valid
- **Background**: `exportBackground: true` includes the white background in exports
- **Output location**: Save exported files alongside the `.excalidraw` file with matching filename (e.g., `system-architecture.excalidraw` → `system-architecture.svg`, `system-architecture.png`)
- **Visual fidelity**: Both exports produce the same visual output as opening in excalidraw.com

## Offline Mode

For air-gapped or low-connectivity environments, cache the bundle locally first.

### One-Time Setup

Run the setup script (PowerShell) from the skill's `lib/` directory:

```powershell
cd .claude/skills/excalidraw/lib
.\setup-offline.ps1
```

This downloads `@excalidraw/utils@0.1.3-test32/es2022/utils.mjs` (~19 MB) into the `lib/` directory. The file is gitignored due to its size; re-run the script on any new machine.

Directory structure after setup:
```
lib/
  @excalidraw/
    utils@0.1.3-test32/
      es2022/
        utils.mjs          ← 19 MB bundle (gitignored)
  node/
    process.mjs            ← 8 KB polyfill (committed)
    buffer.mjs             ← 28 KB polyfill (committed)
  setup-offline.ps1
  .gitignore
```

### Export in Offline Mode

1. **Start the lib server** (in addition to the diagrams server):

```bash
# In one terminal — diagrams directory (for .excalidraw files)
python3 -m http.server 8765

# In another terminal — lib directory (for the bundle)
cd .claude/skills/excalidraw/lib
python3 -m http.server 9090
```

2. **Use the local import URL** instead of the CDN:

```javascript
// Online mode (default)
const { exportToBlob } = await import('https://esm.sh/@excalidraw/utils@0.1.3-test32');

// Offline mode (use after running setup-offline.ps1)
const { exportToBlob } = await import('http://localhost:9090/@excalidraw/utils@0.1.3-test32/es2022/utils.mjs');
```

Everything else in the export procedure (Steps 4–6) remains identical. The local bundle has fonts embedded — no CDN requests are made during export.

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| **Text missing from PNG/SVG** | Use `@excalidraw/utils@0.1.3-test32` — v0.1.2 has a `y="NaN"` bug that makes all text invisible |
| **CORS error posting to save server** | Ensure save server sends `Access-Control-Allow-Origin: *` header on responses AND handles OPTIONS preflight |
| Port already in use | Try a different port: `python3 -m http.server 9876 &` |
| Dynamic import fails (online) | Check network connectivity; `esm.sh` CDN must be reachable |
| Dynamic import fails (offline) | Run `setup-offline.ps1` first; ensure lib server is running on port 9090 |
| PNG is blank/corrupted | Verify the base64 prefix was stripped before decoding |
