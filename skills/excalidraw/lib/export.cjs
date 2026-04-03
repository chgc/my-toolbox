#!/usr/bin/env node
/**
 * excalidraw-export: Convert .excalidraw files to SVG or PNG
 *
 * Usage:
 *   node export.cjs <input.excalidraw> <output.svg>
 *   node export.cjs <input.excalidraw> <output.png>
 *
 * Setup (one-time):
 *   cd .claude/skills/excalidraw/lib && npm install
 */

'use strict';

const fs = require('fs');
const path = require('path');

// ─── Parse CLI args ──────────────────────────────────────────────────────────
const [,, inputFile, outputFile] = process.argv;
if (!inputFile || !outputFile) {
  console.error('Usage: node export.cjs <input.excalidraw> <output.svg|output.png>');
  process.exit(1);
}

const ext = path.extname(outputFile).toLowerCase();
if (ext !== '.svg' && ext !== '.png') {
  console.error('Output file must have .svg or .png extension');
  process.exit(1);
}

// ─── Set up browser globals required by @excalidraw/utils ────────────────────
const { JSDOM } = require('jsdom');
const dom = new JSDOM('<!DOCTYPE html>', { pretendToBeVisual: true });
const w = dom.window;

const browserGlobals = {
  window: w,
  document: w.document,
  HTMLElement: w.HTMLElement,
  SVGElement: w.SVGElement,
  Element: w.Element,
  Node: w.Node,
  CustomEvent: w.CustomEvent,
  Event: w.Event,
  requestAnimationFrame: (cb) => setTimeout(cb, 0),
  cancelAnimationFrame: clearTimeout,
  devicePixelRatio: 1,
  Blob: w.Blob,
  URL: w.URL,
  URLSearchParams: w.URLSearchParams,
  ImageData: w.ImageData,
  Image: w.Image,
};
for (const [k, v] of Object.entries(browserGlobals)) {
  try { global[k] = v; } catch (_) {}
}
global.atob = (s) => Buffer.from(s, 'base64').toString('binary');
global.btoa = (s) => Buffer.from(s, 'binary').toString('base64');

// FontFace mock — needs unicodeRange to avoid "Couldn't transform font-face" warnings
global.FontFace = class FontFace {
  constructor(family, source, descriptors = {}) {
    this.family = family;
    this.status = 'unloaded';
    this.unicodeRange = descriptors.unicodeRange || 'U+0000-10FFFF';
    this.style = descriptors.style || 'normal';
    this.weight = descriptors.weight || 'normal';
    this.stretch = descriptors.stretch || 'normal';
    this.display = descriptors.display || 'auto';
    this.featureSettings = descriptors.featureSettings || 'normal';
    this.variationSettings = descriptors.variationSettings || 'normal';
    this.ascentOverride = descriptors.ascentOverride || 'normal';
    this.descentOverride = descriptors.descentOverride || 'normal';
    this.lineGapOverride = descriptors.lineGapOverride || 'normal';
  }
  load() { this.status = 'loaded'; return Promise.resolve(this); }
};

// ─── Export ───────────────────────────────────────────────────────────────────
const { exportToSvg } = require('@excalidraw/utils');
const data = JSON.parse(fs.readFileSync(inputFile, 'utf8'));

async function main() {
  const svg = await exportToSvg({
    elements: data.elements,
    appState: { ...(data.appState || {}), exportBackground: true },
    files: data.files || {},
  });
  const svgStr = svg.outerHTML;

  if (ext === '.svg') {
    fs.writeFileSync(outputFile, svgStr, 'utf8');
    console.log(`SVG written: ${outputFile}`);
    return;
  }

  // PNG: render SVG with Resvg, supplying the bundled font files
  const { Resvg } = require('@resvg/resvg-js');
  const fontDir = path.join(__dirname, 'node_modules/@excalidraw/utils/dist/prod/assets');

  const fontFiles = fs.existsSync(fontDir)
    ? fs.readdirSync(fontDir)
        .filter((f) => f.endsWith('.ttf'))
        .map((f) => path.join(fontDir, f))
    : [];

  const resvg = new Resvg(svgStr, {
    fitTo: { mode: 'zoom', value: 2 }, // 2× for sharp Retina-quality PNG
    font: {
      fontFiles,
      loadSystemFonts: false,
    },
  });
  const pngBuffer = resvg.render().asPng();
  fs.writeFileSync(outputFile, pngBuffer);
  console.log(`PNG written: ${outputFile} (${Math.round(pngBuffer.length / 1024)} KB)`);
}

main().catch((err) => {
  console.error('Export failed:', err.message);
  process.exit(1);
});
