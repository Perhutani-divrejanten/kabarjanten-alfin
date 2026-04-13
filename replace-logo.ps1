# Script untuk mengganti logo image lama dengan text-based logo di semua HTML files

$WorkspaceRoot = "c:\KULIAH\MAGANG\Magang di Perhutani\Kabar Janten"
$htmlFiles = Get-ChildItem -Path $WorkspaceRoot -Recurse -Include "*.html" -File

$textBasedLogo = @"
<span style="font-weight: bold; color: #0C4A6E; font-size: 24px; letter-spacing: -0.5px;">KABAR<span style="color: #5C2E1A; font-weight: normal; font-size: 18px; margin-left: 2px;">JANTEN</span></span>
"@

$replaceCount = 0

foreach ($file in $htmlFiles) {
    try {
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        $originalContent = $content
        
        # Replace image-based logo with text-based logo in navbar-brand
        $pattern1 = '<img src="img/logo\.png"[^>]*>'
        $pattern2 = '<img[^>]*src="img/logo\.png"[^>]*>'
        $pattern3 = '<img[^>]*src="\.\.\/img\/logo\.png"[^>]*>'
        
        $newContent = $content -replace $pattern1, $textBasedLogo
        $newContent = $newContent -replace $pattern2, $textBasedLogo
        $newContent = $newContent -replace $pattern3, $textBasedLogo
        
        if ($newContent -ne $content) {
            Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8 -NoNewline
            $replaceCount++
            Write-Host "Updated logo in: $($file.Name)"
        }
    } catch {
        Write-Host "Error processing $($file.FullName): $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Logo replacement complete!"
Write-Host "Total files updated: $replaceCount"
