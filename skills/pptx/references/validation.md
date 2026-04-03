# Validation Reference

Validation algorithm and repair script for PPTX files.

---

## Pre-Flight Validation Algorithm

Run BEFORE writing the `.pptx` file:

```
FUNCTION validatePptx(packageDir):
  errors = []

  // 1. sldMasterId range
  presentation = readXml(packageDir + "/ppt/presentation.xml")
  masterId = extractAttribute(presentation, "sldMasterId", "id")
  IF masterId < 2147483648 OR masterId > 4294967295:
    errors.append("sldMasterId={masterId} outside range [2147483648, 4294967295]")

  // 2. sldId range
  FOR each sldId IN extractAll(presentation, "p:sldId", "id"):
    IF sldId < 256 OR sldId > 2147483647:
      errors.append("sldId={sldId} outside range [256, 2147483647]")

  // 3. sldSz consistency
  sldSz = extractElement(presentation, "p:sldSz")
  IF sldSz.type == "screen4x3" AND sldSz.cx != 9144000:
    errors.append("sldSz type=screen4x3 but cx != 9144000")
  IF sldSz.cx > 12000000 AND sldSz.type == "screen4x3":
    errors.append("sldSz looks 16:9 but labeled 4:3")

  // 4. Content_Types completeness
  contentTypes = readXml(packageDir + "/[Content_Types].xml")
  actualSlides = listFiles(packageDir + "/ppt/slides/*.xml")
  FOR each slide IN actualSlides:
    partName = "/ppt/slides/" + slide.name
    IF partName NOT IN contentTypes.overrides:
      errors.append("Missing Content_Type Override for " + partName)

  // 5. Presentation rels completeness
  presRels = readXml(packageDir + "/ppt/_rels/presentation.xml.rels")
  FOR each sldId IN presentation.sldIdLst:
    rId = sldId.r:id
    IF rId NOT IN presRels.relationships:
      errors.append("Slide rId={rId} not found in presentation.xml.rels")

  // 6. Slide structural checks
  FOR each slideFile IN actualSlides:
    content = readText(slideFile)

    // 6a. Namespace order
    IF content.matches('xmlns:p=.*xmlns:r='):
      errors.append(slideFile + ": xmlns:p before xmlns:r (should swap)")

    // 6b. Empty grpSpPr
    IF content.contains('<p:grpSpPr/>'):
      errors.append(slideFile + ": self-closing grpSpPr (needs xfrm children)")

    // 6c. Missing endParaRPr in empty paragraphs
    emptyParas = findAll(content, '<a:pPr[^/]*/>\s*</a:p>')
    IF emptyParas.length > 0:
      errors.append(slideFile + ": " + emptyParas.length + " empty paragraphs without endParaRPr")

    // 6d. Duplicate cNvPr IDs
    ids = extractAll(content, 'cNvPr', 'id')
    duplicates = findDuplicates(ids)
    IF duplicates.length > 0:
      errors.append(slideFile + ": duplicate cNvPr ids: " + duplicates)

    // 6e. Slide rels exist
    relsFile = packageDir + "/ppt/slides/_rels/" + slideFile.name + ".rels"
    IF NOT fileExists(relsFile):
      errors.append(slideFile + ": missing .rels file")

  // 7. Orphan references
  IF fileExists(packageDir + "/ppt/printerSettings"):
    errors.append("printerSettings directory should be removed")

  // 8. Image integrity
  FOR each slideRels IN listFiles(packageDir + "/ppt/slides/_rels/*.rels"):
    FOR each imageRef IN extractImageTargets(slideRels):
      imagePath = resolve(slideRels.dir, imageRef)
      IF NOT fileExists(imagePath):
        errors.append("Missing image: " + imageRef + " (referenced by " + slideRels.name + ")")

  // 9. XML well-formedness
  FOR each xmlFile IN listFiles(packageDir, "**/*.xml", "**/*.rels"):
    TRY parseXml(xmlFile)
    CATCH: errors.append("Malformed XML: " + xmlFile)

  // 10. UTF-8 BOM check
  FOR each xmlFile IN listFiles(packageDir, "**/*.xml"):
    bytes = readBytes(xmlFile)
    IF bytes[0:3] == [0xEF, 0xBB, 0xBF]:
      errors.append("UTF-8 BOM detected: " + xmlFile)

  // 11. tableStyles.xml namespace check
  tableStylesXml = readText(packageDir + "/ppt/tableStyles.xml")
  IF tableStylesXml.contains("p:tblStyleLst") OR NOT tableStylesXml.contains("a:tblStyleLst"):
    errors.append("tableStyles.xml: root element must be a:tblStyleLst (DrawingML), NOT p:tblStyleLst")

  // 12. theme1.xml completeness check
  themeXml = readText(packageDir + "/ppt/theme/theme1.xml")
  IF NOT themeXml.contains("a:objectDefaults"):
    errors.append("theme1.xml: missing <a:objectDefaults/> after </a:themeElements>")
  IF NOT themeXml.contains("a:extraClrSchemeLst"):
    errors.append("theme1.xml: missing <a:extraClrSchemeLst/> after <a:objectDefaults/>")

  // 13. Table style element check (in slide XML)
  FOR each slideFile IN actualSlides:
    content = readText(slideFile)
    IF content.contains("<a:tblStyle"):
      errors.append(slideFile + ": uses <a:tblStyle> (invalid) — must use <a:tableStyleId>")

  // 14. app.xml consistency
  appXml = readXml(packageDir + "/docProps/app.xml")
  declaredSlides = extractText(appXml, "Slides")
  IF declaredSlides != actualSlides.count:
    errors.append("app.xml Slides=" + declaredSlides + " but actual=" + actualSlides.count)

  RETURN errors
```

---

## PowerShell Validation Script

Inline validation you can run immediately:

```powershell
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Test-Pptx {
    param([string]$Path)

    $tempDir = "$env:TEMP\pptx_validate_$(Get-Random)"
    New-Item -ItemType Directory -Path $tempDir | Out-Null
    try {
        [System.IO.Compression.ZipFile]::ExtractToDirectory($Path, $tempDir)
        $issues = @()

        # 1. sldMasterId
        $pres = [System.IO.File]::ReadAllText("$tempDir\ppt\presentation.xml")
        $m = [regex]::Match($pres, 'sldMasterId\s+id="(\d+)"')
        if ($m.Success) {
            $id = [long]$m.Groups[1].Value
            if ($id -lt 2147483648) { $issues += "sldMasterId=$id < 2147483648" }
        }

        # 2. sldSz
        if ($pres -match 'type="screen4x3"' -and $pres -match 'cx="12') {
            $issues += "sldSz type=screen4x3 but cx is 16:9"
        }

        # 3. Empty grpSpPr
        Get-ChildItem "$tempDir\ppt\slides\*.xml" | ForEach-Object {
            $c = [System.IO.File]::ReadAllText($_.FullName)
            if ($c -match '<p:grpSpPr\s*/>') { $issues += "$($_.Name): empty grpSpPr" }
        }

        # 4. Duplicate cNvPr IDs
        Get-ChildItem "$tempDir\ppt\slides\*.xml" | ForEach-Object {
            $c = [System.IO.File]::ReadAllText($_.FullName)
            $ids = [regex]::Matches($c, 'cNvPr\s+id="(\d+)"') | ForEach-Object { $_.Groups[1].Value }
            $ids | Group-Object | Where-Object { $_.Count -gt 1 } | ForEach-Object {
                $issues += "$($_.Name): duplicate cNvPr id=$($_.Name)"
            }
        }

        # 5. app.xml slide count
        $app = [System.IO.File]::ReadAllText("$tempDir\docProps\app.xml")
        $count = [regex]::Match($app, '<Slides>(\d+)</Slides>').Groups[1].Value
        $actual = (Get-ChildItem "$tempDir\ppt\slides\*.xml").Count
        if ($count -ne "$actual") { $issues += "app.xml Slides=$count actual=$actual" }

        # 6. printerSettings
        if (Test-Path "$tempDir\ppt\printerSettings") { $issues += "printerSettings exists" }

        # 7. tableStyles.xml namespace
        $ts = [System.IO.File]::ReadAllText("$tempDir\ppt\tableStyles.xml")
        if ($ts -match 'p:tblStyleLst') { $issues += "tableStyles.xml: uses p:tblStyleLst (WRONG — must be a:tblStyleLst)" }
        if ($ts -notmatch 'a:tblStyleLst') { $issues += "tableStyles.xml: missing a:tblStyleLst root element" }

        # 8. theme1.xml completeness
        $theme = [System.IO.File]::ReadAllText("$tempDir\ppt\theme\theme1.xml")
        if ($theme -notmatch 'a:objectDefaults') { $issues += "theme1.xml: missing <a:objectDefaults/>" }
        if ($theme -notmatch 'a:extraClrSchemeLst') { $issues += "theme1.xml: missing <a:extraClrSchemeLst/>" }

        # 9. Table style element check (tblStyle vs tableStyleId)
        Get-ChildItem "$tempDir\ppt\slides\*.xml" | ForEach-Object {
            $c = [System.IO.File]::ReadAllText($_.FullName)
            if ($c -match '<a:tblStyle\b') { $issues += "$($_.Name): uses <a:tblStyle> — must use <a:tableStyleId>" }
        }

        if ($issues.Count -eq 0) { Write-Host "✅ $Path — No issues" -ForegroundColor Green }
        else { $issues | ForEach-Object { Write-Host "❌ $_" -ForegroundColor Red } }
    } finally {
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
```

---

## Checklist

### Before Generating

- [ ] Planned slide structure (title, sections, content, closing)
- [ ] Chosen slide size (16:9 recommended: `cx=12192000, cy=6858000`)
- [ ] Chosen color theme (dark or light)
- [ ] Assigned rId values for all relationships

### During Generation

- [ ] `sldMasterId` ≥ `2147483648`
- [ ] `sldId` starts at 256, increments by 1
- [ ] `sldSz` type matches dimensions (or omit type for 16:9)
- [ ] Every slide XML has `xmlns:r` before `xmlns:p`
- [ ] Every `<p:grpSpPr>` has `<a:xfrm>` children
- [ ] Every empty `<a:p>` has `<a:endParaRPr/>`
- [ ] No `smtClean` attributes in generated content
- [ ] Shape IDs start at `1` (for nvGrpSpPr) then `2+` per slide
- [ ] No duplicate cNvPr IDs within a slide
- [ ] `tableStyles.xml` uses `a:tblStyleLst` (DrawingML namespace), NOT `p:tblStyleLst`
- [ ] `theme1.xml` includes `<a:objectDefaults/>` and `<a:extraClrSchemeLst/>` after `</a:themeElements>`
- [ ] Table slides use `<a:tableStyleId>{GUID}</a:tableStyleId>`, NOT `<a:tblStyle val="{GUID}"/>`

### After Generation

- [ ] `[Content_Types].xml` has Override for every slide and layout
- [ ] `presentation.xml.rels` has Relationship for every slide
- [ ] Every slide has a matching `.rels` file
- [ ] `app.xml` `<Slides>` matches actual slide count
- [ ] `HeadingPairs` vector size matches content
- [ ] `TitlesOfParts` vector size = fonts + theme + slides
- [ ] All XML files are UTF-8 without BOM
- [ ] ZIP entries use forward slashes
- [ ] No orphan `printerSettings` files or references
- [ ] All image references resolve to existing files

### Common Repair Triggers

| PowerPoint Message | Root Cause |
|-------------------|------------|
| "We found a problem with content" | `sldMasterId < 2147483648` |
| "We found a problem with content" | `tableStyles.xml` uses wrong namespace (`p:tblStyleLst` instead of `a:tblStyleLst`) |
| "We found a problem with content" | `theme1.xml` missing `<a:objectDefaults/>` or `<a:extraClrSchemeLst/>` |
| "We found a problem with content" | Table slide uses `<a:tblStyle val="..."/>` instead of `<a:tableStyleId>` |
| "Removed unreadable content" | Self-closing `<p:grpSpPr/>` |
| "Repaired: Slide N" | Missing endParaRPr, bad namespace order |
| Blank slides | Missing xmlns:r namespace |
| Missing images | Broken rId reference or missing media file |
| "0 slides" in properties | app.xml `<Slides>0</Slides>` |
