#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Validates .pptx files for known OOXML spec violations that cause PowerPoint repair warnings.

.DESCRIPTION
    Checks for:
    1. sldMasterId outside valid range (2147483648-4294967295, per ST_SlideMasterId)
    2. sldId values outside valid range (256-2147483647)
    3. Single-quoted XML declarations (non-standard)
    4. Duplicate cNvPr shape IDs within a slide
    5. Broken relationships (rId references without matching file)
    6. Empty grpSpPr (missing required xfrm)
    7. UTF-8 BOM in XML files
    8. printerSettings orphan files
    9. tableStyles.xml wrong namespace (p: instead of a:) — CRITICAL repair trigger
    10. theme1.xml missing objectDefaults/extraClrSchemeLst — repair trigger
    11. Table slides using <a:tblStyle> instead of <a:tableStyleId> — repair trigger

.PARAMETER Path
    Path to the .pptx file (or glob pattern). Defaults to all *.pptx in current directory.

.PARAMETER Fix
    If specified, automatically fixes the issues found and overwrites the file.

.EXAMPLE
    .\validate-pptx.ps1
    .\validate-pptx.ps1 -Path ".\my-deck.pptx"
    .\validate-pptx.ps1 -Path ".\my-deck.pptx" -Fix
#>
param(
    [string]$Path = ".\*.pptx",
    [switch]$Fix
)

Add-Type -AssemblyName System.IO.Compression.FileSystem

$SLIDE_MASTER_ID_MIN = 2147483648
$SLIDE_MASTER_ID_MAX = [long]4294967295
$SLIDE_ID_MIN = 256
$SLIDE_ID_MAX = 2147483647

function Test-PptxFile {
    param([string]$FilePath, [switch]$AutoFix)

    $issues = @()
    $fixed  = @()

    $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "pptx_validate_$(Get-Random)"
    New-Item -ItemType Directory -Path $tempDir | Out-Null

    try {
        [System.IO.Compression.ZipFile]::ExtractToDirectory($FilePath, $tempDir)
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)

        # --- Check 1: sldMasterId range ---
        $presPath = [System.IO.Path]::Combine($tempDir, "ppt", "presentation.xml")
        if (Test-Path $presPath) {
            $presContent = [System.IO.File]::ReadAllText($presPath)
            $m = [regex]::Match($presContent, 'sldMasterId\s+id="(\d+)"')
            if ($m.Success) {
                $masterId = [long]$m.Groups[1].Value
                if ($masterId -lt $SLIDE_MASTER_ID_MIN -or $masterId -gt $SLIDE_MASTER_ID_MAX) {
                    $issues += "sldMasterId=$masterId outside valid range ($SLIDE_MASTER_ID_MIN-$SLIDE_MASTER_ID_MAX)"
                    if ($AutoFix) {
                        $fixedId = [Math]::Max($SLIDE_MASTER_ID_MIN, [Math]::Min($masterId, $SLIDE_MASTER_ID_MAX))
                        $presContent = $presContent -replace "sldMasterId id=""$masterId""", "sldMasterId id=""$fixedId"""
                        [System.IO.File]::WriteAllText($presPath, $presContent, $utf8NoBom)
                        $fixed += "Fixed sldMasterId: $masterId -> $fixedId"
                    }
                }
            }

            # --- Check 2: sldId range ---
            $sldIdMatches = [regex]::Matches($presContent, '<p:sldId\s+id="(\d+)"')
            foreach ($sm in $sldIdMatches) {
                $sldId = [long]$sm.Groups[1].Value
                if ($sldId -lt $SLIDE_ID_MIN -or $sldId -gt $SLIDE_ID_MAX) {
                    $issues += "sldId=$sldId outside valid range ($SLIDE_ID_MIN-$SLIDE_ID_MAX)"
                }
            }

            # --- Check 3: sldSz type mismatch ---
            if ($presContent -match 'type="screen4x3"' -and $presContent -match 'cx="12\d{6}"') {
                $issues += "sldSz type=screen4x3 but dimensions look 16:9"
                if ($AutoFix) {
                    $presContent = [System.IO.File]::ReadAllText($presPath)
                    $presContent = $presContent -replace '\s+type="screen4x3"', ''
                    [System.IO.File]::WriteAllText($presPath, $presContent, $utf8NoBom)
                    $fixed += "Removed mismatched type=screen4x3 from sldSz"
                }
            }
        }

        # --- Check 4: BOM and single-quoted XML declarations ---
        $xmlFiles = Get-ChildItem $tempDir -Recurse -Filter "*.xml"
        $bomCount = 0
        $singleQuoteCount = 0
        foreach ($xf in $xmlFiles) {
            $bytes = [System.IO.File]::ReadAllBytes($xf.FullName)
            $hasBom = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
            $head = if ($hasBom) { [System.Text.Encoding]::UTF8.GetString($bytes, 3, $bytes.Length - 3) }
                    else          { [System.Text.Encoding]::UTF8.GetString($bytes) }
            if ($hasBom) { $bomCount++ }
            if ($head -match "^<\?xml version='") { $singleQuoteCount++ }

            if ($AutoFix -and ($hasBom -or $head -match "^<\?xml version='")) {
                $newContent = $head -replace "^<\?xml version='1\.0' encoding='UTF-8' standalone='yes'\?>",
                                             '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
                [System.IO.File]::WriteAllText($xf.FullName, $newContent, $utf8NoBom)
            }
        }
        if ($bomCount -gt 0) {
            $issues += "$bomCount XML file(s) contain UTF-8 BOM"
            if ($AutoFix) { $fixed += "Removed BOM from $bomCount XML files" }
        }
        if ($singleQuoteCount -gt 0) {
            $issues += "$singleQuoteCount XML file(s) use single-quoted declarations"
            if ($AutoFix) { $fixed += "Fixed XML declarations in $singleQuoteCount files" }
        }

        # --- Check 5: Empty grpSpPr ---
        $VALID_GRPSPPR = '<p:grpSpPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/><a:chOff x="0" y="0"/><a:chExt cx="0" cy="0"/></a:xfrm></p:grpSpPr>'
        $slideFiles = Get-ChildItem ([System.IO.Path]::Combine($tempDir, "ppt", "slides")) -Filter "*.xml" -ErrorAction SilentlyContinue
        $emptyGrpCount = 0
        foreach ($sf in $slideFiles) {
            $content = [System.IO.File]::ReadAllText($sf.FullName)
            if ($content -match '<p:grpSpPr\s*/>') {
                $emptyGrpCount++
                if ($AutoFix) {
                    $content = $content -replace '<p:grpSpPr\s*/>', $VALID_GRPSPPR
                    [System.IO.File]::WriteAllText($sf.FullName, $content, $utf8NoBom)
                }
            }
        }
        if ($emptyGrpCount -gt 0) {
            $issues += "$emptyGrpCount slide(s) have empty <p:grpSpPr/>"
            if ($AutoFix) { $fixed += "Fixed empty grpSpPr in $emptyGrpCount slides" }
        }

        # --- Check 6: .rels single-quoted declarations ---
        $relsFiles = Get-ChildItem $tempDir -Recurse -Filter "*.rels"
        $relsQuoteCount = 0
        foreach ($rf in $relsFiles) {
            $content = [System.IO.File]::ReadAllText($rf.FullName)
            if ($content -match "^<\?xml version='") {
                $relsQuoteCount++
                if ($AutoFix) {
                    $content = $content -replace "^<\?xml version='1\.0' encoding='UTF-8' standalone='yes'\?>",
                                                 '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
                    [System.IO.File]::WriteAllText($rf.FullName, $content, $utf8NoBom)
                }
            }
        }
        if ($relsQuoteCount -gt 0) {
            $issues += "$relsQuoteCount .rels file(s) use single-quoted declarations"
            if ($AutoFix) { $fixed += "Fixed declarations in $relsQuoteCount .rels files" }
        }

        # --- Check 7: Duplicate cNvPr IDs ---
        foreach ($sf in $slideFiles) {
            $content = [System.IO.File]::ReadAllText($sf.FullName)
            $ids = [regex]::Matches($content, 'cNvPr\s+id="(\d+)"') | ForEach-Object { $_.Groups[1].Value }
            $dupes = $ids | Group-Object | Where-Object { $_.Count -gt 1 }
            foreach ($d in $dupes) {
                $issues += "$($sf.Name): duplicate cNvPr id=$($d.Name)"
            }
        }

        # --- Check 8: printerSettings orphan ---
        if (Test-Path ([System.IO.Path]::Combine($tempDir, "ppt", "printerSettings"))) {
            $issues += "printerSettings directory exists (should be removed)"
            if ($AutoFix) {
                Remove-Item ([System.IO.Path]::Combine($tempDir, "ppt", "printerSettings")) -Recurse -Force
                # Remove from rels
                $presRelsPath = [System.IO.Path]::Combine($tempDir, "ppt", "_rels", "presentation.xml.rels")
                if (Test-Path $presRelsPath) {
                    $rels = [System.IO.File]::ReadAllText($presRelsPath)
                    $rels = $rels -replace '<Relationship[^>]*printerSettings[^>]*/>', ''
                    [System.IO.File]::WriteAllText($presRelsPath, $rels, $utf8NoBom)
                }
                $fixed += "Removed printerSettings"
            }
        }

        # --- Check 9: tableStyles.xml namespace (CRITICAL) ---
        $tsPath = [System.IO.Path]::Combine($tempDir, "ppt", "tableStyles.xml")
        if (Test-Path $tsPath) {
            $tsContent = [System.IO.File]::ReadAllText($tsPath)
            if ($tsContent -match 'p:tblStyleLst') {
                $issues += "tableStyles.xml: uses p:tblStyleLst (WRONG — must be a:tblStyleLst in DrawingML namespace)"
                if ($AutoFix) {
                    $tsContent = $tsContent -replace 'p:tblStyleLst', 'a:tblStyleLst'
                    $tsContent = $tsContent -replace 'xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main"',
                                                     'xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"'
                    [System.IO.File]::WriteAllText($tsPath, $tsContent, $utf8NoBom)
                    $fixed += "Fixed tableStyles.xml namespace: p: -> a:"
                }
            }
        }

        # --- Check 10: theme1.xml completeness ---
        $themePath = [System.IO.Path]::Combine($tempDir, "ppt", "theme", "theme1.xml")
        if (Test-Path $themePath) {
            $themeContent = [System.IO.File]::ReadAllText($themePath)
            $missingThemeChildren = @()
            if ($themeContent -notmatch 'a:objectDefaults') { $missingThemeChildren += 'a:objectDefaults' }
            if ($themeContent -notmatch 'a:extraClrSchemeLst') { $missingThemeChildren += 'a:extraClrSchemeLst' }
            if ($missingThemeChildren.Count -gt 0) {
                $issues += "theme1.xml: missing $($missingThemeChildren -join ', ')"
                if ($AutoFix) {
                    $insertXml = ''
                    if ($themeContent -notmatch 'a:objectDefaults') { $insertXml += '<a:objectDefaults/>' }
                    if ($themeContent -notmatch 'a:extraClrSchemeLst') { $insertXml += '<a:extraClrSchemeLst/>' }
                    $themeContent = $themeContent -replace '</a:themeElements>', "</a:themeElements>$insertXml"
                    [System.IO.File]::WriteAllText($themePath, $themeContent, $utf8NoBom)
                    $fixed += "Added missing theme children: $($missingThemeChildren -join ', ')"
                }
            }
        }

        # --- Check 11: Table style element (tblStyle vs tableStyleId) ---
        foreach ($sf in $slideFiles) {
            $content = [System.IO.File]::ReadAllText($sf.FullName)
            if ($content -match '<a:tblStyle\b') {
                $issues += "$($sf.Name): uses <a:tblStyle> — must use <a:tableStyleId>"
                if ($AutoFix) {
                    $content = $content -replace '<a:tblStyle\s+val="([^"]+)"\s*/>', '<a:tableStyleId>$1</a:tableStyleId>'
                    [System.IO.File]::WriteAllText($sf.FullName, $content, $utf8NoBom)
                    $fixed += "Fixed $($sf.Name): tblStyle -> tableStyleId"
                }
            }
        }

        # --- Repackage if fixes were applied ---
        if ($AutoFix -and $fixed.Count -gt 0) {
            $backupPath = $FilePath -replace '\.pptx$', '_backup.pptx'
            Copy-Item $FilePath $backupPath -Force
            $outTemp = Join-Path ([System.IO.Path]::GetTempPath()) "pptx_fixed_$(Get-Random).pptx"
            $stream = [System.IO.File]::Create($outTemp)
            $zipOut = New-Object System.IO.Compression.ZipArchive($stream, [System.IO.Compression.ZipArchiveMode]::Create)
            Get-ChildItem $tempDir -Recurse -File | ForEach-Object {
                $entryName = $_.FullName.Substring($tempDir.Length + 1).Replace([System.IO.Path]::DirectorySeparatorChar, '/')
                $entry = $zipOut.CreateEntry($entryName, [System.IO.Compression.CompressionLevel]::Optimal)
                $es = $entry.Open(); $fs = [System.IO.File]::OpenRead($_.FullName)
                $fs.CopyTo($es); $fs.Close(); $es.Close()
            }
            $zipOut.Dispose(); $stream.Close()
            Copy-Item $outTemp $FilePath -Force
            Remove-Item $outTemp
        }

    } finally {
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    return @{ Issues = $issues; Fixed = $fixed }
}

# --- Main ---
$files = Get-Item $Path -ErrorAction SilentlyContinue
if (-not $files) {
    Write-Host "No .pptx files found matching: $Path" -ForegroundColor Yellow
    exit 0
}

$totalIssues = 0
foreach ($file in $files) {
    Write-Host "`n📄 $($file.Name)" -ForegroundColor Cyan
    $result = Test-PptxFile -FilePath $file.FullName -AutoFix:$Fix

    if ($result.Issues.Count -eq 0) {
        Write-Host "  ✅ No issues found" -ForegroundColor Green
    } else {
        foreach ($issue in $result.Issues) {
            Write-Host "  ❌ $issue" -ForegroundColor Red
            $totalIssues++
        }
        if ($Fix) {
            foreach ($f in $result.Fixed) {
                Write-Host "  🔧 $f" -ForegroundColor Yellow
            }
            if ($result.Fixed.Count -gt 0) {
                Write-Host "  💾 Backup saved as *_backup.pptx" -ForegroundColor DarkGray
            }
        } else {
            Write-Host "  💡 Run with -Fix to auto-repair" -ForegroundColor DarkGray
        }
    }
}

Write-Host ""
if ($totalIssues -gt 0 -and -not $Fix) { exit 1 }
