# UTF-8 OCR Test Script
param(
    [string]$InputFolder = "input_images",
    [string]$OutputFolder = "output_csv", 
    [string]$Language = "eng+chi_tra"
)

# 設定控制台為 UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$TesseractPath = "D:\Leo\VScode\tesseract\build\bin\Release\tesseract.exe"
$TessdataPath = "D:\Leo\VScode\tesseract\tessdata"

Write-Host "OCR 測試系統 (UTF-8 支援)" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

if (-not (Test-Path $TesseractPath)) {
    Write-Host "錯誤: 找不到 Tesseract" -ForegroundColor Red
    exit 1
}

$env:TESSDATA_PREFIX = $TessdataPath

if (-not (Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
}

$ImageFiles = Get-ChildItem -Path $InputFolder -Include "*.jpg", "*.png", "*.bmp", "*.gif", "*.tiff" -File

if ($ImageFiles.Count -eq 0) {
    Write-Host "沒有找到圖片檔案，請將圖片放入 $InputFolder" -ForegroundColor Yellow
    exit 0
}

Write-Host "找到 $($ImageFiles.Count) 個圖片檔案" -ForegroundColor Green

$Results = @()

foreach ($ImageFile in $ImageFiles) {
    Write-Host "處理: $($ImageFile.Name)" -ForegroundColor Cyan
    
    $TempOutput = "temp_$(Get-Random)"
    
    try {
        & $TesseractPath $ImageFile.FullName $TempOutput -l $Language --psm 6 2>$null
        
        if (Test-Path "$TempOutput.txt") {
            $OcrText = Get-Content "$TempOutput.txt" -Encoding UTF8 -Raw
            $OcrText = $OcrText.Trim() -replace "`r`n", " " -replace "`n", " "
            
            $Results += [PSCustomObject]@{
                FileName = $ImageFile.Name
                Text = $OcrText
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
            
            Write-Host "  成功: $($OcrText.Substring(0, [Math]::Min(30, $OcrText.Length)))..." -ForegroundColor Green
            Remove-Item "$TempOutput.txt" -ErrorAction SilentlyContinue
        } else {
            Write-Host "  失敗" -ForegroundColor Red
            $Results += [PSCustomObject]@{
                FileName = $ImageFile.Name
                Text = "[處理失敗]"
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }
    }
    catch {
        Write-Host "  錯誤: $($_.Exception.Message)" -ForegroundColor Red
    }
}

$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$CsvPath = Join-Path $OutputFolder "ocr_utf8_$Timestamp.csv"

$Results | Export-Csv -Path $CsvPath -Encoding UTF8 -NoTypeInformation

Write-Host ""
Write-Host "處理完成！結果儲存到: $CsvPath" -ForegroundColor Green
Write-Host "使用 UTF-8 編碼，中文應該正常顯示" -ForegroundColor Cyan

Write-Host ""
Write-Host "結果預覽:" -ForegroundColor Yellow
foreach ($Result in $Results) {
    Write-Host "  $($Result.FileName): $($Result.Text)" -ForegroundColor White
}
