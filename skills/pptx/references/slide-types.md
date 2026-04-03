# Slide Types Reference

Patterns for common slide types with complete XML.

---

## Coordinate System

All values are in EMU (English Metric Units):
- 1 inch = 914400 EMU
- 1 cm = 360000 EMU
- 1 pt (font) = 12700 EMU

For a 16:9 slide (`12192000 × 6858000` EMU):
- Full width: `12192000`
- Half width: `6096000`
- Left margin (≈0.6"): `548640`
- Top margin (≈0.75"): `685800`
- Content width (with margins): `11094720`

---

## Slide XML Skeleton

Every slide starts with this structure:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:sld xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
       xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
       xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">
  <p:cSld>
    <p:spTree>
      <p:nvGrpSpPr>
        <p:cNvPr id="1" name=""/>
        <p:cNvGrpSpPr/>
        <p:nvPr/>
      </p:nvGrpSpPr>
      <p:grpSpPr>
        <a:xfrm>
          <a:off x="0" y="0"/>
          <a:ext cx="0" cy="0"/>
          <a:chOff x="0" y="0"/>
          <a:chExt cx="0" cy="0"/>
        </a:xfrm>
      </p:grpSpPr>
      <!-- shapes go here -->
    </p:spTree>
  </p:cSld>
  <p:clrMapOvr><a:masterClrMapping/></p:clrMapOvr>
</p:sld>
```

**Important:**
- `xmlns:r` MUST appear before `xmlns:p`
- `<p:grpSpPr>` MUST have `<a:xfrm>` children (never self-closing)
- Shape `id` starts at `1` for `nvGrpSpPr`, then `2+` for actual shapes

---

## Type 1: Title Slide

Dark background with centered title and subtitle.

```xml
<!-- Full-slide dark background -->
<p:sp>
  <p:nvSpPr><p:cNvPr id="2" name="Background"/><p:cNvSpPr/><p:nvPr/></p:nvSpPr>
  <p:spPr>
    <a:xfrm><a:off x="0" y="0"/><a:ext cx="12192000" cy="6858000"/></a:xfrm>
    <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
    <a:solidFill><a:srgbClr val="1C2B4A"/></a:solidFill>
    <a:ln><a:noFill/></a:ln>
  </p:spPr>
  <p:txBody><a:bodyPr/><a:lstStyle/><a:p><a:endParaRPr/></a:p></p:txBody>
</p:sp>

<!-- Accent bar -->
<p:sp>
  <p:nvSpPr><p:cNvPr id="3" name="Accent Bar"/><p:cNvSpPr/><p:nvPr/></p:nvSpPr>
  <p:spPr>
    <a:xfrm><a:off x="0" y="5120640"/><a:ext cx="12192000" cy="109728"/></a:xfrm>
    <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
    <a:solidFill><a:srgbClr val="326CE5"/></a:solidFill>
    <a:ln><a:noFill/></a:ln>
  </p:spPr>
  <p:txBody><a:bodyPr/><a:lstStyle/><a:p><a:endParaRPr/></a:p></p:txBody>
</p:sp>

<!-- Title text -->
<p:sp>
  <p:nvSpPr><p:cNvPr id="4" name="Title"/><p:cNvSpPr txBox="1"/><p:nvPr/></p:nvSpPr>
  <p:spPr>
    <a:xfrm><a:off x="548640" y="2057400"/><a:ext cx="8229600" cy="1371600"/></a:xfrm>
    <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
    <a:noFill/>
  </p:spPr>
  <p:txBody>
    <a:bodyPr wrap="square"><a:spAutoFit/></a:bodyPr>
    <a:lstStyle/>
    <a:p>
      <a:pPr algn="l"/>
      <a:r>
        <a:rPr lang="zh-TW" sz="4000" b="1">
          <a:solidFill><a:srgbClr val="FFFFFF"/></a:solidFill>
          <a:latin typeface="Calibri"/>
        </a:rPr>
        <a:t>Presentation Title</a:t>
      </a:r>
    </a:p>
  </p:txBody>
</p:sp>

<!-- Subtitle text -->
<p:sp>
  <p:nvSpPr><p:cNvPr id="5" name="Subtitle"/><p:cNvSpPr txBox="1"/><p:nvPr/></p:nvSpPr>
  <p:spPr>
    <a:xfrm><a:off x="548640" y="3657600"/><a:ext cx="8229600" cy="685800"/></a:xfrm>
    <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
    <a:noFill/>
  </p:spPr>
  <p:txBody>
    <a:bodyPr wrap="square"><a:spAutoFit/></a:bodyPr>
    <a:lstStyle/>
    <a:p>
      <a:pPr algn="l"/>
      <a:r>
        <a:rPr lang="zh-TW" sz="2000">
          <a:solidFill><a:srgbClr val="B0BEC5"/></a:solidFill>
          <a:latin typeface="Calibri"/>
        </a:rPr>
        <a:t>Subtitle or description</a:t>
      </a:r>
    </a:p>
  </p:txBody>
</p:sp>
```

---

## Type 2: Section Divider

Full-color background with large number and section title.

```xml
<!-- Blue background -->
<p:sp>
  <p:nvSpPr><p:cNvPr id="2" name="Background"/><p:cNvSpPr/><p:nvPr/></p:nvSpPr>
  <p:spPr>
    <a:xfrm><a:off x="0" y="0"/><a:ext cx="12192000" cy="6858000"/></a:xfrm>
    <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
    <a:solidFill><a:srgbClr val="326CE5"/></a:solidFill>
    <a:ln><a:noFill/></a:ln>
  </p:spPr>
  <p:txBody><a:bodyPr/><a:lstStyle/><a:p><a:endParaRPr/></a:p></p:txBody>
</p:sp>

<!-- Large section number -->
<p:sp>
  <p:nvSpPr><p:cNvPr id="3" name="Number"/><p:cNvSpPr txBox="1"/><p:nvPr/></p:nvSpPr>
  <p:spPr>
    <a:xfrm><a:off x="548640" y="1371600"/><a:ext cx="1828800" cy="1371600"/></a:xfrm>
    <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
    <a:noFill/>
  </p:spPr>
  <p:txBody>
    <a:bodyPr wrap="square"><a:spAutoFit/></a:bodyPr>
    <a:lstStyle/>
    <a:p>
      <a:pPr algn="l"/>
      <a:r>
        <a:rPr lang="en-US" sz="7200" b="1">
          <a:solidFill><a:srgbClr val="FFFFFF"/></a:solidFill>
          <a:latin typeface="Calibri"/>
        </a:rPr>
        <a:t>01</a:t>
      </a:r>
    </a:p>
  </p:txBody>
</p:sp>

<!-- Section title -->
<p:sp>
  <p:nvSpPr><p:cNvPr id="4" name="Section Title"/><p:cNvSpPr txBox="1"/><p:nvPr/></p:nvSpPr>
  <p:spPr>
    <a:xfrm><a:off x="548640" y="2743200"/><a:ext cx="9144000" cy="914400"/></a:xfrm>
    <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
    <a:noFill/>
  </p:spPr>
  <p:txBody>
    <a:bodyPr wrap="square"><a:spAutoFit/></a:bodyPr>
    <a:lstStyle/>
    <a:p>
      <a:pPr algn="l"/>
      <a:r>
        <a:rPr lang="en-US" sz="3600" b="1">
          <a:solidFill><a:srgbClr val="FFFFFF"/></a:solidFill>
          <a:latin typeface="Calibri"/>
        </a:rPr>
        <a:t>Section Title Here</a:t>
      </a:r>
    </a:p>
  </p:txBody>
</p:sp>
```

---

## Type 3: Content Slide (Dark with Header + Body)

```xml
<!-- Dark background -->
<p:sp>
  <p:nvSpPr><p:cNvPr id="2" name="Background"/><p:cNvSpPr/><p:nvPr/></p:nvSpPr>
  <p:spPr>
    <a:xfrm><a:off x="0" y="0"/><a:ext cx="12192000" cy="6858000"/></a:xfrm>
    <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
    <a:solidFill><a:srgbClr val="1C2B4A"/></a:solidFill>
    <a:ln><a:noFill/></a:ln>
  </p:spPr>
  <p:txBody><a:bodyPr/><a:lstStyle/><a:p><a:endParaRPr/></a:p></p:txBody>
</p:sp>

<!-- Top accent bar -->
<p:sp>
  <p:nvSpPr><p:cNvPr id="3" name="Top Bar"/><p:cNvSpPr/><p:nvPr/></p:nvSpPr>
  <p:spPr>
    <a:xfrm><a:off x="0" y="0"/><a:ext cx="12192000" cy="73152"/></a:xfrm>
    <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
    <a:solidFill><a:srgbClr val="326CE5"/></a:solidFill>
    <a:ln><a:noFill/></a:ln>
  </p:spPr>
  <p:txBody><a:bodyPr/><a:lstStyle/><a:p><a:endParaRPr/></a:p></p:txBody>
</p:sp>

<!-- Slide title -->
<p:sp>
  <p:nvSpPr><p:cNvPr id="4" name="Title"/><p:cNvSpPr txBox="1"/><p:nvPr/></p:nvSpPr>
  <p:spPr>
    <a:xfrm><a:off x="548640" y="274320"/><a:ext cx="11094720" cy="548640"/></a:xfrm>
    <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
    <a:noFill/>
  </p:spPr>
  <p:txBody>
    <a:bodyPr wrap="square"><a:spAutoFit/></a:bodyPr>
    <a:lstStyle/>
    <a:p>
      <a:pPr algn="l"/>
      <a:r>
        <a:rPr lang="zh-TW" sz="2800" b="1">
          <a:solidFill><a:srgbClr val="FFFFFF"/></a:solidFill>
          <a:latin typeface="Calibri"/>
        </a:rPr>
        <a:t>Slide Title</a:t>
      </a:r>
    </a:p>
  </p:txBody>
</p:sp>

<!-- Body text -->
<p:sp>
  <p:nvSpPr><p:cNvPr id="5" name="Body"/><p:cNvSpPr txBox="1"/><p:nvPr/></p:nvSpPr>
  <p:spPr>
    <a:xfrm><a:off x="548640" y="1097280"/><a:ext cx="11094720" cy="5486400"/></a:xfrm>
    <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
    <a:noFill/>
  </p:spPr>
  <p:txBody>
    <a:bodyPr wrap="square"><a:spAutoFit/></a:bodyPr>
    <a:lstStyle/>
    <a:p>
      <a:pPr algn="l"/>
      <a:r>
        <a:rPr lang="zh-TW" sz="1800">
          <a:solidFill><a:srgbClr val="E0E0E0"/></a:solidFill>
          <a:latin typeface="Calibri"/>
        </a:rPr>
        <a:t>Body text content here</a:t>
      </a:r>
    </a:p>
  </p:txBody>
</p:sp>
```

---

## Type 4: Image Slide

Add an image with `<p:pic>`:

```xml
<p:pic>
  <p:nvPicPr>
    <p:cNvPr id="6" name="Image 1"/>
    <p:cNvPicPr><a:picLocks noChangeAspect="1"/></p:cNvPicPr>
    <p:nvPr/>
  </p:nvPicPr>
  <p:blipFill>
    <a:blip r:embed="rId2"/>
    <a:stretch><a:fillRect/></a:stretch>
  </p:blipFill>
  <p:spPr>
    <a:xfrm>
      <a:off x="1524000" y="1371600"/>
      <a:ext cx="9144000" cy="4572000"/>
    </a:xfrm>
    <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
  </p:spPr>
</p:pic>
```

**Requirements:**
- `r:embed="rId2"` must match the slide's `.rels` file
- The `.rels` must point to `../media/imageN.ext`
- The image file must exist in `ppt/media/`
- `[Content_Types].xml` must have `<Default>` for the image extension

---

## Type 5: Table Slide

Tables use `<a:graphic>` inside a `<p:graphicFrame>`:

```xml
<p:graphicFrame>
  <p:nvGraphicFramePr>
    <p:cNvPr id="6" name="Table 1"/>
    <p:cNvGraphicFramePr><a:graphicFrameLocks noGrp="1"/></p:cNvGraphicFramePr>
    <p:nvPr/>
  </p:nvGraphicFramePr>
  <p:xfrm>
    <a:off x="548640" y="1371600"/>
    <a:ext cx="11094720" cy="4114800"/>
  </p:xfrm>
  <a:graphic>
    <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/table">
      <a:tbl>
        <a:tblPr firstRow="1" bandRow="1">
          <a:tableStyleId>{5C22544A-7EE6-4342-B048-85BDC9FD1C3A}</a:tableStyleId>
        </a:tblPr>
        <a:tblGrid>
          <a:gridCol w="3698240"/>
          <a:gridCol w="3698240"/>
          <a:gridCol w="3698240"/>
        </a:tblGrid>
        <!-- Header row -->
        <a:tr h="548640">
          <a:tc>
            <a:txBody>
              <a:bodyPr/><a:lstStyle/>
              <a:p><a:r><a:rPr lang="en-US" sz="1400" b="1"/><a:t>Column 1</a:t></a:r></a:p>
            </a:txBody>
            <a:tcPr>
              <a:solidFill><a:srgbClr val="326CE5"/></a:solidFill>
            </a:tcPr>
          </a:tc>
          <a:tc>
            <a:txBody>
              <a:bodyPr/><a:lstStyle/>
              <a:p><a:r><a:rPr lang="en-US" sz="1400" b="1"/><a:t>Column 2</a:t></a:r></a:p>
            </a:txBody>
            <a:tcPr>
              <a:solidFill><a:srgbClr val="326CE5"/></a:solidFill>
            </a:tcPr>
          </a:tc>
          <a:tc>
            <a:txBody>
              <a:bodyPr/><a:lstStyle/>
              <a:p><a:r><a:rPr lang="en-US" sz="1400" b="1"/><a:t>Column 3</a:t></a:r></a:p>
            </a:txBody>
            <a:tcPr>
              <a:solidFill><a:srgbClr val="326CE5"/></a:solidFill>
            </a:tcPr>
          </a:tc>
        </a:tr>
        <!-- Data row -->
        <a:tr h="457200">
          <a:tc>
            <a:txBody>
              <a:bodyPr/><a:lstStyle/>
              <a:p><a:r><a:rPr lang="en-US" sz="1400"/><a:t>Value 1</a:t></a:r></a:p>
            </a:txBody>
            <a:tcPr/>
          </a:tc>
          <a:tc>
            <a:txBody>
              <a:bodyPr/><a:lstStyle/>
              <a:p><a:r><a:rPr lang="en-US" sz="1400"/><a:t>Value 2</a:t></a:r></a:p>
            </a:txBody>
            <a:tcPr/>
          </a:tc>
          <a:tc>
            <a:txBody>
              <a:bodyPr/><a:lstStyle/>
              <a:p><a:r><a:rPr lang="en-US" sz="1400"/><a:t>Value 3</a:t></a:r></a:p>
            </a:txBody>
            <a:tcPr/>
          </a:tc>
        </a:tr>
      </a:tbl>
    </a:graphicData>
  </a:graphic>
</p:graphicFrame>
```

---

## Bullet Points

Use `<a:buChar>` or `<a:buAutoNum>` for bullets:

```xml
<a:p>
  <a:pPr marL="342900" indent="-342900">
    <a:buChar char="•"/>
  </a:pPr>
  <a:r>
    <a:rPr lang="en-US" sz="1800">
      <a:solidFill><a:srgbClr val="E0E0E0"/></a:solidFill>
    </a:rPr>
    <a:t>Bullet point text</a:t>
  </a:r>
</a:p>
```

Nested bullets — increase `marL`:

| Level | marL | indent |
|-------|------|--------|
| 1 | `342900` | `-342900` |
| 2 | `742950` | `-285750` |
| 3 | `1143000` | `-228600` |

---

## Multi-line Text Runs

Each paragraph is an `<a:p>`. For multiple paragraphs:

```xml
<p:txBody>
  <a:bodyPr wrap="square"><a:spAutoFit/></a:bodyPr>
  <a:lstStyle/>
  <a:p>
    <a:r><a:rPr lang="zh-TW" sz="1800"/><a:t>First paragraph</a:t></a:r>
  </a:p>
  <a:p>
    <a:r><a:rPr lang="zh-TW" sz="1800"/><a:t>Second paragraph</a:t></a:r>
  </a:p>
</p:txBody>
```

For **bold** or _italic_ within a run:

```xml
<a:r><a:rPr lang="en-US" sz="1800" b="1"/><a:t>Bold text</a:t></a:r>
<a:r><a:rPr lang="en-US" sz="1800" i="1"/><a:t>Italic text</a:t></a:r>
<a:r><a:rPr lang="en-US" sz="1800" b="1" i="1"/><a:t>Bold italic</a:t></a:r>
```
