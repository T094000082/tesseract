# PowerShell PDF OCR 測試腳本
param(
    [string]$InputFolder = "input_pdfs",
    [string]$OutputFolder = "output_csv",
    [string]$Language = "eng+chi_tra"
)

# 設定路徑
$TesseractPath = "D:\Leo\VScode\tesseract\build\bin\Release\tesseract.exe"
$TessdataPath = "D:\Leo\VScode\tesseract\tessdata"

Write-Host "==================================================" -ForegroundColor Green
Write-Host "           PDF OCR 轉 CSV 系統 (簡化版)" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""

# 檢查 Tesseract
if (-not (Test-Path $TesseractPath)) {
    Write-Host "錯誤: 找不到 Tesseract: $TesseractPath" -ForegroundColor Red
    exit 1
}

# 檢查 tessdata
if (-not (Test-Path $TessdataPath)) {
    Write-Host "錯誤: 找不到 tessdata: $TessdataPath" -ForegroundColor Red
    exit 1
}

# 設定環境變數
$env:TESSDATA_PREFIX = $TessdataPath

# 建立輸出資料夾
if (-not (Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
}

Write-Host "設定資訊:" -ForegroundColor Yellow
Write-Host "- Tesseract: $TesseractPath"
Write-Host "- 語言資料: $TessdataPath"
Write-Host "- 輸入資料夾: $InputFolder"
Write-Host "- 輸出資料夾: $OutputFolder"
Write-Host "- 語言: $Language"
Write-Host ""

# 檢查輸入資料夾中的圖片檔案
$ImageFiles = Get-ChildItem -Path $InputFolder -Include "*.jpg", "*.jpeg", "*.png", "*.bmp", "*.tiff", "*.gif" -Recurse -ErrorAction SilentlyContinue

if ($ImageFiles.Count -eq 0) {
    Write-Host "注意: 在 $InputFolder 中沒有找到圖片檔案" -ForegroundColor Yellow
    Write-Host "支援的格式: JPG, PNG, BMP, TIFF, GIF" -ForegroundColor Yellow
    Write-Host "請將圖片檔案放入 $InputFolder 資料夾中" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "按任意鍵退出..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 0
}

Write-Host "找到 $($ImageFiles.Count) 個圖片檔案" -ForegroundColor Green
Write-Host ""

# 建立 CSV 結果陣列
$Results = @()

# 處理每個圖片檔案
foreach ($ImageFile in $ImageFiles) {
    Write-Host "處理: $($ImageFile.Name)" -ForegroundColor Cyan
    
    try {
        # 執行 OCR
        $OcrOutput = & $TesseractPath $ImageFile.FullName stdout -l $Language --psm 6 2>$null
        
        if ($LASTEXITCODE -eq 0) {
            $Results += [PSCustomObject]@{
                FileName = $ImageFile.Name
                FilePath = $ImageFile.FullName
                Text = $OcrOutput -replace "`r`n", " " -replace "`n", " "
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
            Write-Host "  ✓ 成功" -ForegroundColor Green
        } else {
            Write-Host "  ✗ OCR 失敗" -ForegroundColor Red
            $Results += [PSCustomObject]@{
                FileName = $ImageFile.Name
                FilePath = $ImageFile.FullName
                Text = "[OCR 處理失敗]"
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }
    }
    catch {
        Write-Host "  ✗ 錯誤: $($_.Exception.Message)" -ForegroundColor Red
        $Results += [PSCustomObject]@{
            FileName = $ImageFile.Name
            FilePath = $ImageFile.FullName
            Text = "[處理錯誤: $($_.Exception.Message)]"
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
    }
}

# 儲存結果到 CSV
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$CsvPath = Join-Path $OutputFolder "ocr_results_$Timestamp.csv"

try {
    $Results | Export-Csv -Path $CsvPath -Encoding UTF8 -NoTypeInformation
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Green
    Write-Host "             處理完成！" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "結果已儲存到: $CsvPath" -ForegroundColor Yellow
    Write-Host "處理了 $($Results.Count) 個檔案" -ForegroundColor Yellow
    
    # 顯示結果摘要
    Write-Host ""
    Write-Host "結果摘要:" -ForegroundColor Cyan
    foreach ($Result in $Results) {
        $TextPreview = if ($Result.Text.Length -gt 50) { 
            $Result.Text.Substring(0, 50) + "..." 
        } else { 
            $Result.Text 
        }
        Write-Host "  $($Result.FileName): $TextPreview" -ForegroundColor White
    }
}
catch {
    Write-Host "CSV 儲存失敗: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "按任意鍵退出..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
