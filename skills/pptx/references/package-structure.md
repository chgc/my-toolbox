# Package Structure Reference

Complete file layout for a valid `.pptx` (OOXML Presentation) package.

---

## Directory Layout

```
my-presentation.pptx (ZIP archive)
├── [Content_Types].xml          ← MIME types for all parts
├── _rels/
│   └── .rels                    ← Root relationships
├── docProps/
│   ├── app.xml                  ← Application metadata
│   ├── core.xml                 ← Dublin Core metadata
│   └── thumbnail.jpeg           ← (optional) thumbnail
├── ppt/
│   ├── presentation.xml         ← Main presentation definition
│   ├── presProps.xml            ← Presentation properties
│   ├── tableStyles.xml          ← Table style definitions
│   ├── viewProps.xml            ← View/zoom settings
│   ├── _rels/
│   │   └── presentation.xml.rels ← Presentation relationships
│   ├── media/                   ← (optional) Embedded images
│   │   ├── image1.png
│   │   └── image2.jpg
│   ├── slideLayouts/
│   │   ├── slideLayout1.xml     ← Title Slide layout
│   │   ├── slideLayout2.xml     ← Title + Content layout
│   │   ├── ...
│   │   └── _rels/
│   │       ├── slideLayout1.xml.rels
│   │       └── ...
│   ├── slideMasters/
│   │   ├── slideMaster1.xml     ← Slide master
│   │   └── _rels/
│   │       └── slideMaster1.xml.rels
│   ├── slides/
│   │   ├── slide1.xml
│   │   ├── slide2.xml
│   │   ├── ...
│   │   └── _rels/
│   │       ├── slide1.xml.rels
│   │       ├── slide2.xml.rels
│   │       └── ...
│   └── theme/
│       └── theme1.xml           ← Color/font theme
```

---

## Minimum Viable Package

For a working PPTX, you need at minimum:

1. `[Content_Types].xml`
2. `_rels/.rels`
3. `docProps/app.xml`
4. `docProps/core.xml`
5. `ppt/presentation.xml`
6. `ppt/_rels/presentation.xml.rels`
7. `ppt/presProps.xml`
8. `ppt/tableStyles.xml`
9. `ppt/viewProps.xml`
10. `ppt/theme/theme1.xml`
11. `ppt/slideMasters/slideMaster1.xml`
12. `ppt/slideMasters/_rels/slideMaster1.xml.rels`
13. At least one `ppt/slideLayouts/slideLayoutN.xml` + its `.rels`
14. At least one `ppt/slides/slideN.xml` + its `.rels`

---

## Relationship ID (rId) Conventions

### presentation.xml.rels

| rId | Target | Type |
|-----|--------|------|
| `rId1` | `slideMasters/slideMaster1.xml` | slideMaster |
| `rId2` | `presProps.xml` | presProps |
| `rId3` | `viewProps.xml` | viewProps |
| `rId4` | `theme/theme1.xml` | theme |
| `rId5` | `tableStyles.xml` | tableStyles |
| `rId6+` | `slides/slideN.xml` | slide (one per slide) |

### slideN.xml.rels

| rId | Target | Type |
|-----|--------|------|
| `rId1` | `../slideLayouts/slideLayoutN.xml` | slideLayout |
| `rId2+` | `../media/imageN.ext` | image (if slide has images) |

### slideMaster1.xml.rels

| rId | Target | Type |
|-----|--------|------|
| `rId1+` | `../slideLayouts/slideLayoutN.xml` | slideLayout (all layouts) |
| `rIdN` | `../theme/theme1.xml` | theme |

---

## [Content_Types].xml

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="jpeg" ContentType="image/jpeg"/>
  <Default Extension="png" ContentType="image/png"/>
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
  <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
  <Override PartName="/ppt/presProps.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.presProps+xml"/>
  <Override PartName="/ppt/presentation.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml"/>
  <Override PartName="/ppt/tableStyles.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.tableStyles+xml"/>
  <Override PartName="/ppt/slideMasters/slideMaster1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml"/>
  <Override PartName="/ppt/theme/theme1.xml" ContentType="application/vnd.openxmlformats-officedocument.theme+xml"/>
  <!-- Add one Override per slideLayout -->
  <Override PartName="/ppt/slideLayouts/slideLayout1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml"/>
  <!-- Add one Override per slide -->
  <Override PartName="/ppt/slides/slide1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slide+xml"/>
</Types>
```

**Important:** Every slide and slideLayout MUST have an `<Override>` entry. Missing entries cause "unreadable content" errors.

---

## _rels/.rels

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="ppt/presentation.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
</Relationships>
```

---

## Adding Images

When a slide contains images:

1. Place the image file in `ppt/media/imageN.png`
2. Add a `<Default>` entry to `[Content_Types].xml` for the extension
3. Add a `<Relationship>` to the slide's `.rels` file:
   ```xml
   <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="../media/image1.png"/>
   ```
4. Reference `rId2` in the slide XML via `<a:blip r:embed="rId2"/>`
