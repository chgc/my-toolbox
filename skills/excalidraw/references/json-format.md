# Excalidraw JSON Format Reference

Complete reference for Excalidraw JSON structure and element types.

---

## File Structure

```json
{
  "type": "excalidraw",
  "version": 2,
  "source": "claude-code-excalidraw-skill",
  "elements": [],
  "appState": {
    "gridSize": 20,
    "viewBackgroundColor": "#ffffff"
  },
  "files": {}
}
```

---

## Element Types

| Type | Use For | Arrow Reliability |
|------|---------|-------------------|
| `rectangle` | Services, components, databases, containers, orchestrators, decision points | Excellent |
| `ellipse` | Users, external systems, start/end points | Good |
| `text` | Labels inside shapes, titles, annotations | N/A |
| `arrow` | Data flow, connections, dependencies | N/A |
| `line` | Grouping boundaries, separators | N/A |

### BANNED: Diamond Shapes

**NEVER use `type: "diamond"` in generated diagrams.**

Diamond arrow connections are fundamentally broken in raw Excalidraw JSON:
- Excalidraw applies `roundness` to diamond vertices during rendering
- Visual edges appear offset from mathematical edge points
- No offset formula reliably compensates
- Arrows appear disconnected/floating

**Use styled rectangles instead** for visual distinction:

| Semantic Meaning | Rectangle Style |
|------------------|-----------------|
| Orchestrator/Hub | Coral (`#ffa8a8`/`#c92a2a`) + strokeWidth: 3 |
| Decision Point | Orange (`#ffd8a8`/`#e8590c`) + dashed stroke |
| Central Router | Larger size + bold color |

---

## Required Element Properties

Every element MUST have these properties:

```json
{
  "id": "unique-id-string",
  "type": "rectangle",
  "x": 100,
  "y": 100,
  "width": 200,
  "height": 80,
  "angle": 0,
  "strokeColor": "#1971c2",
  "backgroundColor": "#a5d8ff",
  "fillStyle": "solid",
  "strokeWidth": 2,
  "strokeStyle": "solid",
  "roughness": 0,
  "opacity": 100,
  "groupIds": [],
  "frameId": null,
  "roundness": { "type": 3 },
  "seed": 1,
  "version": 1,
  "versionNonce": 1,
  "isDeleted": false,
  "boundElements": null,
  "updated": 1,
  "link": null,
  "locked": false,
  "index": "a1"
}
```

---

## Text Inside Shapes (Labels)

**Every labeled shape requires TWO elements:**

### Shape with boundElements

```json
{
  "id": "{component-id}",
  "type": "rectangle",
  "x": 500,
  "y": 200,
  "width": 200,
  "height": 90,
  "strokeColor": "#1971c2",
  "backgroundColor": "#a5d8ff",
  "boundElements": [{ "type": "text", "id": "{component-id}-text" }],
  // ... other required properties
}
```

### Text with containerId

```json
{
  "id": "{component-id}-text",
  "type": "text",
  "x": 505,                          // shape.x + 5
  "y": 220,                          // shape.y + (shape.height - text.height) / 2
  "width": 190,                      // shape.width - 10
  "height": 50,
  "strokeColor": "#1e1e2e",          // ⚠️ ALWAYS use near-black for text — NEVER inherit shape color
  "text": "{Component Name}\n{Subtitle}",
  "fontSize": 16,
  "fontFamily": 3,                   // Code (Cascadia) — recommended default
  "textAlign": "center",
  "verticalAlign": "middle",
  "containerId": "{component-id}",
  "originalText": "{Component Name}\n{Subtitle}",
  "lineHeight": 1.25,
  "index": "a2",
  // ... other required properties
}
```

### DO NOT Use the `label` Property

The `label` property is for the JavaScript API, NOT raw JSON files:

```json
// WRONG - will show empty boxes
{ "type": "rectangle", "label": { "text": "My Label" } }

// CORRECT - requires TWO elements
// 1. Shape with boundElements reference
// 2. Separate text element with containerId
```

### Text Color Rule

**ALL text elements MUST use `"strokeColor": "#1e1e2e"`** (near-black) regardless of the parent shape's color.

- ✅ Text inside a blue shape → `strokeColor: "#1e1e2e"`
- ✅ Standalone title text → `strokeColor: "#1e1e2e"`
- ✅ Arrow labels → `strokeColor: "#1e1e2e"`
- ❌ Never copy the parent shape's strokeColor into the text element

This ensures readability across all background colors.

### Text Positioning

- Text `x` = shape `x` + 5
- Text `y` = shape `y` + (shape.height - text.height) / 2
- Text `width` = shape `width` - 10
- Use `\n` for multi-line labels
- Always use `textAlign: "center"` and `verticalAlign: "middle"`

### ID Naming Convention

Always use pattern: `{shape-id}-text` for text element IDs.

---

## Dynamic ID Generation

IDs and labels are generated from codebase analysis:

| Discovered Component | Generated ID | Generated Label |
|---------------------|--------------|-----------------|
| Express API server | `express-api` | `"API Server\nExpress.js"` |
| PostgreSQL database | `postgres-db` | `"PostgreSQL\nDatabase"` |
| Redis cache | `redis-cache` | `"Redis\nCache Layer"` |
| S3 bucket for uploads | `s3-uploads` | `"S3 Bucket\nuploads/"` |
| Lambda function | `lambda-processor` | `"Lambda\nProcessor"` |
| React frontend | `react-frontend` | `"React App\nFrontend"` |

---

## Grouping with Dashed Rectangles

For logical groupings (namespaces, VPCs, pipelines):

```json
{
  "id": "group-ai-pipeline",
  "type": "rectangle",
  "x": 100,
  "y": 500,
  "width": 1000,
  "height": 280,
  "strokeColor": "#9c36b5",
  "backgroundColor": "transparent",
  "strokeStyle": "dashed",
  "roughness": 0,
  "roundness": null,
  "boundElements": null
}
```

Group labels are standalone text (no containerId) at top-left:

```json
{
  "id": "group-ai-pipeline-label",
  "type": "text",
  "x": 120,
  "y": 510,
  "text": "AI Processing Pipeline (Cloud Run)",
  "textAlign": "left",
  "verticalAlign": "top",
  "containerId": null
}
```

---

## Font Family Values

Use `fontFamily` in text elements. Default is Excalifont (5), but **use Virgil (1) for diagrams with CJK (Chinese/Japanese/Korean) text** — it falls back gracefully to system CJK fonts.

| Value | Font | Notes |
|-------|------|-------|
| 1 | Virgil | Hand-drawn; ✅ recommended for CJK diagrams |
| 2 | Helvetica | Clean sans-serif |
| 3 | Cascadia | Monospace; good for code/tech labels |
| 5 | Excalifont | **New default** in excalidraw v0.17+ |
| 6 | Nunito | (was value 5 in older versions) |
| 7 | Lilita One | Display font |
| 8 | Comic Shanns | Comic-style monospace |
| 9 | Liberation Sans | Open-source sans-serif |
| 10 | Assistant | Hebrew-compatible sans-serif |
| 100 | Xiaolai | CJK hand-drawn fallback (automatic) |

> **⚠️ Note on font value history**: Value `5` changed meaning in v0.17+ — it used to be Nunito, now it's Excalifont. Nunito moved to `6`. If you see diagrams that were generated with `fontFamily: 5` expecting Nunito, the text will now render as Excalifont.

---

## `index` Property

All elements should include an `index` field — a fractional ordering string used by excalidraw for collaboration/reconciliation:

```json
{ "index": "a1" }   // first element
{ "index": "a2" }   // second element
{ "index": "a3" }   // etc.
```

Use sequential values `"a1"`, `"a2"`, `"a3"` ... for generated diagrams. This property is optional for local-only use but recommended for compatibility.
```
