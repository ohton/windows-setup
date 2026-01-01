# Winget Cache Cleaner
# Winget installer cache checker and remover

param(
    [switch]$Force
)

Write-Host "=== Winget Cache Cleaner ===" -ForegroundColor Cyan
Write-Host ""

$cachePaths = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalCache",
    "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\TempState",
    "$env:TEMP\WinGet"
)

$totalSize = 0
$foundCaches = @()

foreach ($path in $cachePaths) {
    if (Test-Path $path) {
        $size = (Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        
        if ($size -gt 0) {
            $sizeInMB = [math]::Round($size / 1MB, 2)
            Write-Host "Path: $path" -ForegroundColor Yellow
            Write-Host "Size: $sizeInMB MB" -ForegroundColor Green
            Write-Host ""
            
            $foundCaches += @{
                Path = $path
                Size = $size
            }
            $totalSize += $size
        }
    }
}

if ($foundCaches.Count -eq 0) {
    Write-Host "No cache found." -ForegroundColor Green
    exit 0
}

$totalSizeInMB = [math]::Round($totalSize / 1MB, 2)
Write-Host "Total cache size: $totalSizeInMB MB" -ForegroundColor Cyan
Write-Host ""

if (-not $Force) {
    $confirmation = Read-Host "Delete cache? (Y/N)"
    if ($confirmation -ne 'Y' -and $confirmation -ne 'y') {
        Write-Host "Cancelled." -ForegroundColor Yellow
        exit 0
    }
}

Write-Host ""
Write-Host "Deleting cache..." -ForegroundColor Yellow

$deletedSize = 0
foreach ($cache in $foundCaches) {
    try {
        $path = $cache.Path
        Write-Host "Deleting: $path" -ForegroundColor Gray
        
        Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        
        $deletedSize += $cache.Size
        Write-Host "Completed" -ForegroundColor Green
    }
    catch {
        Write-Host "Error occurred: $_" -ForegroundColor Red
    }
}

$deletedSizeInMB = [math]::Round($deletedSize / 1MB, 2)
Write-Host ""
Write-Host "=== Completed ===" -ForegroundColor Cyan
Write-Host "Deleted size: $deletedSizeInMB MB" -ForegroundColor Green
