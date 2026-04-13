# Final Verification Script - Memastikan rebrand Kabar Janten selesai dengan baik

$WorkspaceRoot = "c:\KULIAH\MAGANG\Magang di Perhutani\Kabar Janten"

Write-Host "========== FINAL VERIFICATION - KABAR JANTEN REBRAND ==========" -ForegroundColor Cyan
Write-Host ""

$issues = @()
$stats = @{
    "Files checked" = 0
    "Old branding found" = 0
    "Legacy logo refs" = 0
    "New colors found" = 0
}

$siteFiles = Get-ChildItem -Path $WorkspaceRoot -Recurse -Include "*.html", "*.css", "*.js", "*.json", "*.md", "*.toml" -File |
    Where-Object {
        $_.FullName -notlike "*\node_modules\*" -and
        $_.FullName -notlike "*\.bak*" -and
        $_.Name -notin @("REBRAND_SUMMARY.txt")
    }
$stats["Files checked"] = $siteFiles.Count

# 1. Check for old branding strings
Write-Host "1. Checking for old branding strings..." -ForegroundColor Yellow
$oldBrandingPatterns = @("Indonesia Daily", "indonesiadaily", "IndonesiaDaily", "Warta Janten", "WartaJanten", "wartajanten")

foreach ($pattern in $oldBrandingPatterns) {
    $found = $siteFiles | Select-String -Pattern $pattern -ErrorAction SilentlyContinue
    if ($found) {
        foreach ($result in $found) {
            $issues += @{
                Type = "Old Branding"
                File = ($result.Path | Split-Path -Leaf)
                Line = $result.LineNumber
                Pattern = $pattern
            }
            $stats["Old branding found"]++
        }
    }
}

if ($stats["Old branding found"] -eq 0) {
    Write-Host "   ✅ No old branding references found in site content!" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Found old branding in $($stats['Old branding found']) places" -ForegroundColor Yellow
}

# 2. Check for legacy logo image references
Write-Host "2. Checking for legacy logo image references..." -ForegroundColor Yellow
$logoFound = $siteFiles |
    Select-String -Pattern 'logo\.png' -ErrorAction SilentlyContinue

if ($logoFound) {
    $stats["Legacy logo refs"] = $logoFound.Count
    Write-Host "   ⚠️  Found $($logoFound.Count) legacy logo references" -ForegroundColor Yellow
    foreach ($ref in $logoFound | Select-Object -First 5) {
        Write-Host "      - $($ref.Path | Split-Path -Leaf)" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ✅ No legacy logo image references found!" -ForegroundColor Green
}

# 3. Check for new colors in CSS
Write-Host "3. Checking for new color scheme in CSS files..." -ForegroundColor Yellow
$cssFiles = Get-ChildItem -Path (Join-Path $WorkspaceRoot "css") -Include "*.css" -File -ErrorAction SilentlyContinue

$newColors = @("#0C4A6E", "#082F49", "#5C2E1A")
$colorsFound = 0

foreach ($color in $newColors) {
    $found = $cssFiles | Select-String -Pattern $color -ErrorAction SilentlyContinue
    if ($found) {
        $colorsFound++
        Write-Host "   ✅ Found $color in CSS" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Not found: $color" -ForegroundColor Yellow
    }
}

# 4. Check for new branding
Write-Host "4. Checking for new branding 'Kabar Janten'..." -ForegroundColor Yellow
$newBrandingFound = $siteFiles |
    Select-String -Pattern "Kabar Janten|KabarJanten|kabarjanten" -ErrorAction SilentlyContinue |
    Measure-Object

if ($newBrandingFound.Count -gt 0) {
    Write-Host "   ✅ Found 'Kabar Janten' branding in $($newBrandingFound.Count) places" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  No 'Kabar Janten' branding found!" -ForegroundColor Yellow
    $issues += @{ Type = "Missing"; File = "All"; Reason = "No Kabar Janten branding found" }
}

# 5. Check package.json updates
Write-Host "5. Checking package metadata..." -ForegroundColor Yellow
$pkgFiles = Get-ChildItem -Path $WorkspaceRoot -Recurse -Include "package.json", "package-lock.json" -File |
    Where-Object { $_.FullName -notlike "*\node_modules\*" }

$pkgOK = 0
foreach ($pkg in $pkgFiles) {
    $content = Get-Content $pkg.FullName -Raw
    if ($content -match '"name"\s*:\s*"kabarjanten') {
        $pkgOK++
        Write-Host "   ✅ $($pkg.Name) has proper branding" -ForegroundColor Green
    }
}

# Summary
Write-Host ""
Write-Host "========== SUMMARY ==========" -ForegroundColor Cyan
Write-Host "Files checked: $($stats['Files checked'])" -ForegroundColor White
Write-Host "Old branding issues: $($stats['Old branding found'])" -ForegroundColor $(if ($stats["Old branding found"] -eq 0) { "Green" } else { "Yellow" })
Write-Host "Legacy logo references: $($stats['Legacy logo refs'])" -ForegroundColor $(if ($stats["Legacy logo refs"] -eq 0) { "Green" } else { "Yellow" })
Write-Host "New color scheme found: $colorsFound/3" -ForegroundColor $(if ($colorsFound -eq 3) { "Green" } else { "Yellow" })
Write-Host ""

if ($issues.Count -gt 0) {
    Write-Host "[!] Issues found:" -ForegroundColor Yellow
    $issues | Select-Object -First 5 | ForEach-Object {
        Write-Host "   - $($_.File): $($_.Type) - $($_.Pattern)" -ForegroundColor Yellow
    }
    if ($issues.Count -gt 5) {
        Write-Host "   ... and $($issues.Count - 5) more" -ForegroundColor Yellow
    }
} else {
    Write-Host "[OK] No critical issues found!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Rebrand Kabar Janten SELESAI" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Cyan
