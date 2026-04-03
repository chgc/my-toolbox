#!/usr/bin/env node
/**
 * mermaid-render: Convert Mermaid diagram text to SVG or PNG
 *
 * Uses @mermaid-js/mermaid-cli (mmdc) for accurate, browser-quality rendering.
 * Supports all Mermaid diagram types: flowchart, sequence, class, ER, gantt, etc.
 *
 * Usage:
 *   node render.cjs <input.mmd> <output.svg>
 *   node render.cjs <input.mmd> <output.png>
 *   node render.cjs <input.mmd> <output.png> --theme dark
 *   node render.cjs <input.mmd> <output.png> --width 1920 --height 1080
 *   node render.cjs <input.mmd> <output.png> --background-color transparent
 *
 * Setup (one-time):
 *   cd .claude/skills/mermaid/lib && npm install
 *
 * Note: First run downloads Chromium (~170MB). Subsequent runs are fast.
 */

'use strict';

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// ─── Parse CLI args ───────────────────────────────────────────────────────────
const args = process.argv.slice(2);

const positional = [];
const extraArgs = [];
let i = 0;
while (i < args.length) {
  if (args[i].startsWith('--') || args[i].startsWith('-')) {
    extraArgs.push(args[i]);
    if (i + 1 < args.length && !args[i + 1].startsWith('-')) {
      extraArgs.push(args[i + 1]);
      i += 2;
    } else {
      i++;
    }
  } else {
    positional.push(args[i]);
    i++;
  }
}

const [inputFile, outputFile] = positional;

if (!inputFile || !outputFile) {
  console.error('Usage: node render.cjs <input.mmd> <output.svg|output.png> [options]');
  console.error('');
  console.error('Options (passed directly to mmdc):');
  console.error('  --theme <theme>              Theme: default, dark, forest, neutral, base');
  console.error('  --width <px>                 Output width in pixels (default: 800)');
  console.error('  --height <px>                Output height in pixels');
  console.error('  --background-color <color>   Background color (default: white; use transparent for PNG)');
  console.error('  --scale <factor>             Scale factor for PNG (default: 1)');
  console.error('  --config-file <path>         Mermaid config JSON file');
  process.exit(1);
}

if (!fs.existsSync(inputFile)) {
  console.error('Input file not found: ' + inputFile);
  process.exit(1);
}

const ext = path.extname(outputFile).toLowerCase();
if (ext !== '.svg' && ext !== '.png') {
  console.error('Output file must have .svg or .png extension');
  process.exit(1);
}

// ─── Locate mmdc binary ───────────────────────────────────────────────────────
// On Windows use .cmd wrapper; on Unix use the shell script
const mmdcBin = process.platform === 'win32'
  ? path.join(__dirname, 'node_modules', '.bin', 'mmdc.cmd')
  : path.join(__dirname, 'node_modules', '.bin', 'mmdc');

const mmdcCheck = process.platform === 'win32'
  ? path.join(__dirname, 'node_modules', '.bin', 'mmdc.cmd')
  : path.join(__dirname, 'node_modules', '.bin', 'mmdc');

if (!fs.existsSync(mmdcCheck)) {
  console.error('mmdc not found. Run: cd .claude/skills/mermaid/lib && npm install');
  process.exit(1);
}

// ─── Ensure output directory exists ──────────────────────────────────────────
fs.mkdirSync(path.dirname(path.resolve(outputFile)), { recursive: true });

// ─── Build command string ─────────────────────────────────────────────────────
// Use quoted paths to handle spaces; shell:true handles .cmd on Windows
function q(s) {
  return '"' + s.replace(/"/g, '\\"') + '"';
}

const cmdParts = [
  q(mmdcBin),
  '--input', q(path.resolve(inputFile)),
  '--output', q(path.resolve(outputFile)),
  ...extraArgs,
];
const cmd = cmdParts.join(' ');

// ─── Run mmdc ─────────────────────────────────────────────────────────────────
try {
  console.log('Rendering ' + inputFile + ' -> ' + outputFile + ' ...');
  execSync(cmd, { stdio: 'inherit', shell: true });

  const stat = fs.statSync(outputFile);
  console.log('Done. ' + ext.toUpperCase() + ' written: ' + outputFile + ' (' + Math.round(stat.size / 1024) + ' KB)');
} catch (err) {
  console.error('Render failed. Try running mmdc directly:');
  console.error('  ' + cmd);
  process.exit(1);
}
