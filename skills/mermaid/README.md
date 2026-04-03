# Mermaid Diagram Generator

Convert Mermaid text diagrams to PNG or SVG — cross-platform, no visible browser.

## Setup (one-time)

```powershell
cd .claude/skills/mermaid/lib && npm install
```

> Downloads Chromium (~170 MB) on first install for headless rendering.

## Usage

```powershell
# SVG output
node .claude/skills/mermaid/lib/render.cjs diagram.mmd diagram.svg

# PNG output (2x resolution)
node .claude/skills/mermaid/lib/render.cjs diagram.mmd diagram.png --scale 2

# Dark theme
node .claude/skills/mermaid/lib/render.cjs diagram.mmd diagram.png --theme dark
```

## Quick Example

Create `diagram.mmd`:
```
flowchart TD
    A[Browser] --> B[API Gateway]
    B --> C[Auth]
    B --> D[Services]
    C --> E[(DB)]
    D --> E
```

Run:
```powershell
node .claude/skills/mermaid/lib/render.cjs diagram.mmd diagram.png
```

## Supported Diagram Types

flowchart, sequenceDiagram, classDiagram, erDiagram, stateDiagram-v2, gantt, pie, gitGraph, mindmap, timeline, xychart-beta

## References

- `references/diagram-types.md` — Complete examples for each diagram type
- `references/syntax-cheatsheet.md` — Quick syntax reference
- `references/theming.md` — Themes, colors, config options
