# XML Templates Reference

Ready-to-use XML templates for every required PPTX part. Copy and adapt these directly.

---

## presentation.xml

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:presentation xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
                xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
                xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main"
                saveSubsetFonts="1" autoCompressPictures="0">
  <p:sldMasterIdLst>
    <p:sldMasterId id="2147483648" r:id="rId1"/>
  </p:sldMasterIdLst>
  <p:sldIdLst>
    <!-- One entry per slide, starting at id="256" -->
    <p:sldId id="256" r:id="rId6"/>
    <p:sldId id="257" r:id="rId7"/>
  </p:sldIdLst>
  <p:sldSz cx="12192000" cy="6858000"/>
  <p:notesSz cx="6858000" cy="9144000"/>
  <p:defaultTextStyle>
    <a:defPPr>
      <a:defRPr lang="en-US"/>
    </a:defPPr>
    <a:lvl1pPr marL="0" algn="l" defTabSz="457200" rtl="0" eaLnBrk="1" latinLnBrk="0" hangingPunct="1">
      <a:defRPr sz="1800" kern="1200">
        <a:solidFill><a:schemeClr val="tx1"/></a:solidFill>
        <a:latin typeface="+mn-lt"/>
        <a:ea typeface="+mn-ea"/>
        <a:cs typeface="+mn-cs"/>
      </a:defRPr>
    </a:lvl1pPr>
  </p:defaultTextStyle>
</p:presentation>
```

**Key rules:**
- `sldMasterId id` ≥ `2147483648`
- `sldId id` starts at `256`, increments by 1
- `sldSz` — do NOT include `type` attribute for 16:9
- rId for slides must match `presentation.xml.rels`

---

## presentation.xml.rels

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster" Target="slideMasters/slideMaster1.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/presProps" Target="presProps.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/viewProps" Target="viewProps.xml"/>
  <Relationship Id="rId4" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme" Target="theme/theme1.xml"/>
  <Relationship Id="rId5" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/tableStyles" Target="tableStyles.xml"/>
  <!-- One per slide, rId6+ -->
  <Relationship Id="rId6" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide" Target="slides/slide1.xml"/>
  <Relationship Id="rId7" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide" Target="slides/slide2.xml"/>
</Relationships>
```

---

## presProps.xml

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:presentationPr xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
                  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
                  xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">
  <p:extLst>
    <p:ext uri="{E76CE94A-603C-4142-B9EB-6D1370010A27}">
      <p14:discardImageEditData xmlns:p14="http://schemas.microsoft.com/office/powerpoint/2010/main" val="0"/>
    </p:ext>
    <p:ext uri="{D31A062A-798A-4329-ABDD-BBA856620510}">
      <p14:defaultImageDpi xmlns:p14="http://schemas.microsoft.com/office/powerpoint/2010/main" val="0"/>
    </p:ext>
    <p:ext uri="{FD5EFAAD-0ECE-453E-9831-46B23BE46B34}">
      <p15:chartTrackingRefBased xmlns:p15="http://schemas.microsoft.com/office/powerpoint/2012/main" val="0"/>
    </p:ext>
  </p:extLst>
</p:presentationPr>
```

---

## viewProps.xml

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:viewPr xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
          xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
          xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">
  <p:normalViewPr>
    <p:restoredLeft sz="19979" autoAdjust="0"/>
    <p:restoredTop sz="94660"/>
  </p:normalViewPr>
  <p:slideViewPr>
    <p:cSldViewPr snapToGrid="0" snapToObjects="1">
      <p:cViewPr varScale="1">
        <p:scale><a:sx n="100" d="100"/><a:sy n="100" d="100"/></p:scale>
        <p:origin x="0" y="0"/>
      </p:cViewPr>
      <p:guideLst>
        <p:guide orient="horz" pos="2160"/>
        <p:guide pos="2880"/>
      </p:guideLst>
    </p:cSldViewPr>
  </p:slideViewPr>
  <p:notesTextViewPr>
    <p:cViewPr>
      <p:scale><a:sx n="100" d="100"/><a:sy n="100" d="100"/></p:scale>
      <p:origin x="0" y="0"/>
    </p:cViewPr>
  </p:notesTextViewPr>
  <p:gridSpacing cx="76200" cy="76200"/>
</p:viewPr>
```

---

## tableStyles.xml

> ⚠️ **CRITICAL:** The root element is `a:tblStyleLst` in the **DrawingML** namespace (`a:`), NOT `p:tblStyleLst` in PresentationML. Using the wrong namespace (`p:`) causes PowerPoint to show a repair warning. Despite the Content-Type being labeled `presentationml.tableStyles`, the XML element belongs to the DrawingML schema (`CT_TableStyleList`).

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<a:tblStyleLst xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" def="{5C22544A-7EE6-4342-B048-85BDC9FD1C3A}"/>
```

```xml
<!-- ❌ WRONG — causes repair warning! -->
<p:tblStyleLst xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main" def="{...}"/>
```

---

## docProps/app.xml

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties"
            xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
  <TotalTime>1</TotalTime>
  <Words>0</Words>
  <Application>Microsoft Office PowerPoint</Application>
  <PresentationFormat>自訂</PresentationFormat>
  <Paragraphs>0</Paragraphs>
  <Slides>{SLIDE_COUNT}</Slides>
  <Notes>0</Notes>
  <HiddenSlides>0</HiddenSlides>
  <MMClips>0</MMClips>
  <ScaleCrop>false</ScaleCrop>
  <HeadingPairs>
    <vt:vector size="6" baseType="variant">
      <vt:variant><vt:lpstr>使用字型</vt:lpstr></vt:variant>
      <vt:variant><vt:i4>2</vt:i4></vt:variant>
      <vt:variant><vt:lpstr>佈景主題</vt:lpstr></vt:variant>
      <vt:variant><vt:i4>1</vt:i4></vt:variant>
      <vt:variant><vt:lpstr>投影片標題</vt:lpstr></vt:variant>
      <vt:variant><vt:i4>{SLIDE_COUNT}</vt:i4></vt:variant>
    </vt:vector>
  </HeadingPairs>
  <TitlesOfParts>
    <vt:vector size="{VECTOR_SIZE}" baseType="lpstr">
      <vt:lpstr>Arial</vt:lpstr>
      <vt:lpstr>Calibri</vt:lpstr>
      <vt:lpstr>Office Theme</vt:lpstr>
      <!-- One vt:lpstr per slide title -->
    </vt:vector>
  </TitlesOfParts>
  <Company></Company>
  <LinksUpToDate>false</LinksUpToDate>
  <SharedDoc>false</SharedDoc>
  <HyperlinksChanged>false</HyperlinksChanged>
  <AppVersion>16.0000</AppVersion>
</Properties>
```

**Placeholders:**
- `{SLIDE_COUNT}` — number of slides
- `{VECTOR_SIZE}` — `SLIDE_COUNT + 3` (fonts + theme + slides)

---

## docProps/core.xml

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
                   xmlns:dc="http://purl.org/dc/elements/1.1/"
                   xmlns:dcterms="http://purl.org/dc/terms/"
                   xmlns:dcmitype="http://purl.org/dc/dcmitype/"
                   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <dc:title>{TITLE}</dc:title>
  <dc:subject></dc:subject>
  <dc:creator>Claude Code</dc:creator>
  <cp:keywords></cp:keywords>
  <dc:description>Generated by Claude Code PPTX skill</dc:description>
  <cp:lastModifiedBy>Claude Code</cp:lastModifiedBy>
  <cp:revision>1</cp:revision>
  <dcterms:created xsi:type="dcterms:W3CDTF">{ISO_DATETIME}</dcterms:created>
  <dcterms:modified xsi:type="dcterms:W3CDTF">{ISO_DATETIME}</dcterms:modified>
  <cp:category></cp:category>
</cp:coreProperties>
```

---

## theme/theme1.xml

> ⚠️ **CRITICAL:** `<a:objectDefaults/>` and `<a:extraClrSchemeLst/>` MUST be present (even if empty). PowerPoint expects these elements after `</a:themeElements>`. Omitting them can trigger repair warnings.

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<a:theme xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" name="CustomTheme">
  <a:themeElements>
    <a:clrScheme name="Custom">
      <a:dk1><a:srgbClr val="1C2B4A"/></a:dk1>
      <a:lt1><a:srgbClr val="FFFFFF"/></a:lt1>
      <a:dk2><a:srgbClr val="326CE5"/></a:dk2>
      <a:lt2><a:srgbClr val="E0E0E0"/></a:lt2>
      <a:accent1><a:srgbClr val="326CE5"/></a:accent1>
      <a:accent2><a:srgbClr val="4FC3F7"/></a:accent2>
      <a:accent3><a:srgbClr val="66BB6A"/></a:accent3>
      <a:accent4><a:srgbClr val="FFA726"/></a:accent4>
      <a:accent5><a:srgbClr val="AB47BC"/></a:accent5>
      <a:accent6><a:srgbClr val="EF5350"/></a:accent6>
      <a:hlink><a:srgbClr val="4FC3F7"/></a:hlink>
      <a:folHlink><a:srgbClr val="B0BEC5"/></a:folHlink>
    </a:clrScheme>
    <a:fontScheme name="Custom">
      <a:majorFont><a:latin typeface="Calibri"/><a:ea typeface=""/><a:cs typeface=""/></a:majorFont>
      <a:minorFont><a:latin typeface="Calibri"/><a:ea typeface=""/><a:cs typeface=""/></a:minorFont>
    </a:fontScheme>
    <a:fmtScheme name="Custom">
      <a:fillStyleLst>
        <a:solidFill><a:schemeClr val="phClr"/></a:solidFill>
        <a:solidFill><a:schemeClr val="phClr"/></a:solidFill>
        <a:solidFill><a:schemeClr val="phClr"/></a:solidFill>
      </a:fillStyleLst>
      <a:lnStyleLst>
        <a:ln w="6350" cap="flat" cmpd="sng" algn="ctr"><a:solidFill><a:schemeClr val="phClr"/></a:solidFill><a:prstDash val="solid"/></a:ln>
        <a:ln w="12700" cap="flat" cmpd="sng" algn="ctr"><a:solidFill><a:schemeClr val="phClr"/></a:solidFill><a:prstDash val="solid"/></a:ln>
        <a:ln w="19050" cap="flat" cmpd="sng" algn="ctr"><a:solidFill><a:schemeClr val="phClr"/></a:solidFill><a:prstDash val="solid"/></a:ln>
      </a:lnStyleLst>
      <a:effectStyleLst>
        <a:effectStyle><a:effectLst/></a:effectStyle>
        <a:effectStyle><a:effectLst/></a:effectStyle>
        <a:effectStyle><a:effectLst/></a:effectStyle>
      </a:effectStyleLst>
      <a:bgFillStyleLst>
        <a:solidFill><a:schemeClr val="phClr"/></a:solidFill>
        <a:solidFill><a:schemeClr val="phClr"/></a:solidFill>
        <a:solidFill><a:schemeClr val="phClr"/></a:solidFill>
      </a:bgFillStyleLst>
    </a:fmtScheme>
  </a:themeElements>
  <a:objectDefaults/>
  <a:extraClrSchemeLst/>
</a:theme>
```

**Key rules:**
- `<a:objectDefaults/>` and `<a:extraClrSchemeLst/>` — MUST be present after `</a:themeElements>`, even if empty
- All 12 color slots in `<a:clrScheme>` are required (dk1, lt1, dk2, lt2, accent1–6, hlink, folHlink)
- `<a:fillStyleLst>` needs exactly 3 fills, `<a:lnStyleLst>` needs 3 lines, `<a:effectStyleLst>` needs 3 effects, `<a:bgFillStyleLst>` needs 3 fills

---

## Slide .rels Template

### Basic slide (text only)

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout" Target="../slideLayouts/slideLayout7.xml"/>
</Relationships>
```

### Slide with image

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout" Target="../slideLayouts/slideLayout7.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="../media/image1.png"/>
</Relationships>
```

> **Note:** `slideLayout7.xml` is "Blank" layout — the safest default for custom-generated slides.
