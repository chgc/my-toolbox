---
name: pptx
description: Generate valid .pptx (PowerPoint) files that open without repair warnings in the latest Microsoft Office. Use when the user asks to create presentations, slide decks, PowerPoint files, or export content to PPTX format. Handles slide layout, text, images, tables, and OOXML compliance.
---

# PPTX Generator

Generate valid `.pptx` files that open cleanly in Microsoft Office PowerPoint (latest version) with **zero repair warnings**.

---

## Quick Start

**User just asks:**
```
"Create a PowerPoint presentation about X"
"Generate a slide deck for this project"
"Export these notes to PPTX"
```

**Claude Code will:**
1. Analyze the content / codebase / notes
2. Plan slide structure and layout
3. Generate OOXML-compliant XML parts
4. Package as a valid `.pptx` ZIP archive
5. Validate before saving

**No prerequisites:** Pure PowerShell — no python-pptx, no npm packages needed.

---

## Critical Rules

### 1. sldMasterId MUST Be ≥ 2147483648

The OOXML spec `ST_SlideMasterId` defines `minInclusive = 2147483648` (0x80000000).

```xml
<!-- ✅ CORRECT -->
<p:sldMasterId id="2147483648" r:id="rId1"/>

<!-- ❌ WRONG — triggers PowerPoint repair warning -->
<p:sldMasterId id="2147483647" r:id="rId1"/>
```

> This is the #1 cause of "file is broken" warnings. python-pptx gets this wrong.

### 2. sldId Range: 256–2147483647

Every `<p:sldId>` must have `id` in range `[256, 2147483647]`. Start at 256 and increment.

```xml
<p:sldId id="256" r:id="rId2"/>
<p:sldId id="257" r:id="rId3"/>
```

### 3. sldSz Must Match Actual Dimensions

Do NOT mix `type` attribute with non-matching dimensions:

```xml
<!-- ✅ 16:9 widescreen -->
<p:sldSz cx="12192000" cy="6858000"/>

<!-- ✅ 4:3 standard -->
<p:sldSz cx="9144000" cy="6858000" type="screen4x3"/>

<!-- ❌ WRONG — 16:9 dimensions with 4:3 type -->
<p:sldSz cx="12192000" cy="6858000" type="screen4x3"/>
```

### 4. Namespace Ordering: xmlns:r Before xmlns:p

PowerPoint expects `xmlns:r` declared before `xmlns:p` in slide XML:

```xml
<!-- ✅ CORRECT order -->
<p:sld xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
       xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
       xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">

<!-- ❌ Avoid: xmlns:p before xmlns:r -->
```

### 5. Every Empty Paragraph Needs `<a:endParaRPr/>`

PowerPoint adds `<a:endParaRPr/>` to all paragraphs that don't end with a text run:

```xml
<!-- ✅ CORRECT -->
<a:p><a:pPr algn="ctr"/><a:endParaRPr/></a:p>

<!-- ❌ Missing endParaRPr — PowerPoint will "repair" it -->
<a:p><a:pPr algn="ctr"/></a:p>
```

### 6. grpSpPr Must Have xfrm Children

Never use self-closing `<p:grpSpPr/>`. Always include the full transform:

```xml
<!-- ✅ CORRECT -->
<p:grpSpPr>
  <a:xfrm>
    <a:off x="0" y="0"/>
    <a:ext cx="0" cy="0"/>
    <a:chOff x="0" y="0"/>
    <a:chExt cx="0" cy="0"/>
  </a:xfrm>
</p:grpSpPr>
```

### 7. No smtClean Attribute in Generated Content

Do NOT add `smtClean="0"` to `<a:rPr>` elements — PowerPoint removes most of them during repair.

### 8. UTF-8 Without BOM

All XML files must be UTF-8 encoded **without** BOM (Byte Order Mark). Use:
```powershell
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
```

### 9. ZIP Entry Paths Use Forward Slashes

When creating the `.pptx` ZIP archive, entry names must use `/` not `\`:
```powershell
$entryName = $relativePath.Replace('\', '/')
```

### 10. Do NOT Include printerSettings

The `printerSettings1.bin` is a binary blob that causes issues across platforms. Omit it entirely — PowerPoint regenerates it on first print.

### 11. tableStyles.xml Uses DrawingML Namespace

The `tableStyles.xml` root element is `a:tblStyleLst` in the **DrawingML** namespace, NOT `p:tblStyleLst`:

```xml
<!-- ✅ CORRECT — DrawingML namespace -->
<a:tblStyleLst xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" def="{5C22544A-7EE6-4342-B048-85BDC9FD1C3A}"/>

<!-- ❌ WRONG — PresentationML namespace triggers repair warning -->
<p:tblStyleLst xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main" def="{...}"/>
```

> Despite the Content-Type being `presentationml.tableStyles+xml`, the XML element uses the DrawingML schema (`CT_TableStyleList`).

### 12. theme1.xml Must Have objectDefaults and extraClrSchemeLst

PowerPoint expects these elements after `</a:themeElements>`, even though the OOXML spec marks them as optional:

```xml
<!-- ✅ CORRECT -->
  </a:themeElements>
  <a:objectDefaults/>
  <a:extraClrSchemeLst/>
</a:theme>

<!-- ❌ WRONG — omitting these triggers repair warning -->
  </a:themeElements>
</a:theme>
```

### 13. Table Style Reference: Use tableStyleId, Not tblStyle

Inside `<a:tblPr>`, reference the table style GUID with `<a:tableStyleId>`:

```xml
<!-- ✅ CORRECT -->
<a:tblPr firstRow="1" bandRow="1">
  <a:tableStyleId>{5C22544A-7EE6-4342-B048-85BDC9FD1C3A}</a:tableStyleId>
</a:tblPr>

<!-- ❌ WRONG — <a:tblStyle> does not exist in OOXML spec -->
<a:tblPr firstRow="1" bandRow="1">
  <a:tblStyle val="{5C22544A-7EE6-4342-B048-85BDC9FD1C3A}"/>
</a:tblPr>
```

---

## Slide Sizes (EMU Values)

All coordinates in OOXML use EMU (English Metric Units): 1 inch = 914400 EMU.

| Aspect Ratio | cx (width) | cy (height) | Notes |
|--------------|-----------|-------------|-------|
| **16:9** | `12192000` | `6858000` | Modern default |
| **4:3** | `9144000` | `6858000` | Legacy |
| **16:10** | `10972800` | `6858000` | Mac default |
| **A4 Portrait** | `6858000` | `9692640` | Print-oriented |
| **Widescreen Custom** | `12188825` | `6858000` | PowerPoint-native 16:9 variant |

---

## Workflow

### Step 1: Plan Content

Organize content into slides:
- **Title slide** — project name, subtitle, date
- **Section dividers** — chapter headers with numbering
- **Content slides** — text, bullet points, tables, images
- **Closing slide** — summary, Q&A, contact info

### Step 2: Generate Package Structure

Create the OOXML package parts. See `references/package-structure.md` for the full file layout.

### Step 3: Write XML Parts

Generate each XML file. See `references/xml-templates.md` for templates of every required file.

### Step 4: Add Slides

For each slide, create:
1. `ppt/slides/slideN.xml` — slide content
2. `ppt/slides/_rels/slideN.xml.rels` — relationship to slideLayout

See `references/slide-types.md` for layout patterns (title, content, section divider, image, table).

### Step 5: Validate

Run the validation checklist before packaging. See `references/validation.md`.

### Step 6: Package as ZIP

Assemble the `.pptx` file using `System.IO.Compression`:
```powershell
$stream = [System.IO.File]::Create($outputPath)
$zip = New-Object System.IO.Compression.ZipArchive($stream, 'Create')
# ... add entries with forward-slash paths ...
$zip.Dispose(); $stream.Close()
```

---

## Color Palettes

### Professional Dark Theme (recommended)

| Element | Background | Text/Stroke |
|---------|-----------|-------------|
| Slide bg | `#1C2B4A` | — |
| Accent bar | `#326CE5` | — |
| Title text | — | `#FFFFFF` |
| Body text | — | `#E0E0E0` |
| Highlight | `#4FC3F7` | — |
| Card bg | `#263B5E` | `#FFFFFF` |
| Success | `#66BB6A` | — |
| Warning | `#FFA726` | — |
| Danger | `#EF5350` | — |

### Light Theme

| Element | Background | Text/Stroke |
|---------|-----------|-------------|
| Slide bg | `#FFFFFF` | — |
| Accent bar | `#0078D4` | — |
| Title text | — | `#1A1A1A` |
| Body text | — | `#333333` |
| Card bg | `#F5F5F5` | `#1A1A1A` |

---

## Quick Validation Checklist

Before writing file:
- [ ] `sldMasterId` ≥ `2147483648`
- [ ] All `sldId` values in range `[256, 2147483647]`
- [ ] `sldSz` type matches actual cx/cy dimensions
- [ ] No self-closing `<p:grpSpPr/>`
- [ ] All empty paragraphs have `<a:endParaRPr/>`
- [ ] No `smtClean` attributes in generated content
- [ ] All XML files are UTF-8 without BOM
- [ ] ZIP entries use forward slashes
- [ ] `[Content_Types].xml` lists every slide, layout, and master
- [ ] `presentation.xml.rels` has relationship for every slide
- [ ] No orphan `printerSettings` references
- [ ] `app.xml` `<Slides>` count matches actual slide count
- [ ] `tableStyles.xml` uses `a:tblStyleLst` (DrawingML), NOT `p:tblStyleLst`
- [ ] `theme1.xml` has `<a:objectDefaults/>` and `<a:extraClrSchemeLst/>`
- [ ] Table slides use `<a:tableStyleId>`, NOT `<a:tblStyle>`

**Full validation:** See `references/validation.md`

---

## Common Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| "File is broken, needs repair" | `sldMasterId < 2147483648` | Set to `2147483648` |
| "File is broken, needs repair" | `tableStyles.xml` uses `p:tblStyleLst` | Use `a:tblStyleLst` (DrawingML namespace) |
| "File is broken, needs repair" | `theme1.xml` missing `objectDefaults`/`extraClrSchemeLst` | Add `<a:objectDefaults/>` and `<a:extraClrSchemeLst/>` after `</a:themeElements>` |
| "File is broken, needs repair" | Table uses `<a:tblStyle val="..."/>` | Use `<a:tableStyleId>{GUID}</a:tableStyleId>` |
| "Repaired: removed unreadable content" | Self-closing `<p:grpSpPr/>` | Add `<a:xfrm>` children |
| Blank slides after repair | Missing `xmlns:r` namespace | Add all 3 required namespaces |
| Slide count shows 0 | `app.xml` not updated | Set `<Slides>N</Slides>` |
| Images not showing | Missing image rels or Content_Type | Add `.rels` + `[Content_Types].xml` entry |
| Text encoding garbled | BOM in XML | Use UTF-8 without BOM |

---

## Reference Files

| File | Contents |
|------|----------|
| `references/package-structure.md` | Complete file layout, Content_Types, relationships |
| `references/xml-templates.md` | Ready-to-use XML templates for every part |
| `references/slide-types.md` | Slide patterns: title, content, section, image, table |
| `references/validation.md` | Full validation algorithm and repair script |

---

## Output

- **Location:** Same directory as source content, or user-specified
- **Filename:** Descriptive, e.g., `project-overview.pptx`
- **Testing:** Open in Microsoft PowerPoint — should show NO repair dialog
