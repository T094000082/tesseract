param(
    [string]$InputFolder = "input_images",
    [string]$OutputFolder = "output_csv",
    [string]$Language = "eng+chi_tra"
)

# 設定路徑
$TesseractPath = "D:\Leo\VScode\tesseract\build\bin\Release\tesseract.exe"
$TessdataPath = "D:\Leo\VScode\tesseract\tessdata"

Write-Host "==================================================" -ForegroundColor Green
Write-Host "           OCR 測試系統" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

# 檢查 Tesseract
if (-not (Test-Path $TesseractPath)) {
    Write-Host "錯誤: 找不到 Tesseract: $TesseractPath" -ForegroundColor Red
    Read-Host "按 Enter 鍵退出"
    exit 1
}

# 設定環境變數
$env:TESSDATA_PREFIX = $TessdataPath

# 建立輸出資料夾
if (-not (Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
}

Write-Host "設定資訊:"
Write-Host "- Tesseract: $TesseractPath"
Write-Host "- 語言資料: $TessdataPath" 
Write-Host "- 輸入資料夾: $InputFolder"
Write-Host "- 輸出資料夾: $OutputFolder"
Write-Host "- 語言: $Language"
Write-Host ""

# 檢查輸入資料夾
if (-not (Test-Path $InputFolder)) {
    Write-Host "建立輸入資料夾: $InputFolder" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $InputFolder -Force | Out-Null
}

# 尋找圖片檔案
$ImageFiles = @()
$Extensions = @("*.jpg", "*.jpeg", "*.png", "*.bmp", "*.tiff", "*.gif")

foreach ($ext in $Extensions) {
    $files = Get-ChildItem -Path $InputFolder -Filter $ext -ErrorAction SilentlyContinue
    $ImageFiles += $files
}

if ($ImageFiles.Count -eq 0) {
    Write-Host "注意: 在 $InputFolder 中沒有找到圖片檔案" -ForegroundColor Yellow
    Write-Host "支援的格式: JPG, PNG, BMP, TIFF, GIF" -ForegroundColor Yellow
    Write-Host "請將圖片檔案放入 $InputFolder 資料夾中" -ForegroundColor Yellow
    Read-Host "按 Enter 鍵退出"
    exit 0
}

Write-Host "找到 $($ImageFiles.Count) 個圖片檔案" -ForegroundColor Green
Write-Host ""

# 建立結果陣列
$Results = @()

# 處理每個圖片檔案
foreach ($ImageFile in $ImageFiles) {
    Write-Host "處理: $($ImageFile.Name)" -ForegroundColor Cyan
    
    try {
        # 執行 OCR
        $Arguments = @($ImageFile.FullName, "stdout", "-l", $Language, "--psm", "6")
        $ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
        $ProcessInfo.FileName = $TesseractPath
        $ProcessInfo.RedirectStandardOutput = $true
        $ProcessInfo.RedirectStandardError = $true
        $ProcessInfo.UseShellExecute = $false
        $ProcessInfo.CreateNoWindow = $true
        $ProcessInfo.EnvironmentVariables["TESSDATA_PREFIX"] = $TessdataPath
        
        foreach ($arg in $Arguments) {
            $ProcessInfo.Arguments += "`"$arg`" "
        }
        
        $Process = New-Object System.Diagnostics.Process
        $Process.StartInfo = $ProcessInfo
        $Process.Start() | Out-Null
        $Process.WaitForExit()
        
        $OcrOutput = $Process.StandardOutput.ReadToEnd()
        $ErrorOutput = $Process.StandardError.ReadToEnd()
        
        if ($Process.ExitCode -eq 0) {
            $Results += [PSCustomObject]@{
                FileName = $ImageFile.Name
                FilePath = $ImageFile.FullName
                Text = $OcrOutput.Trim() -replace "`r`n", " " -replace "`n", " "
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
            Write-Host "  ✓ 成功" -ForegroundColor Green
        } else {
            Write-Host "  ✗ OCR 失敗: $ErrorOutput" -ForegroundColor Red
            $Results += [PSCustomObject]@{
                FileName = $ImageFile.Name
                FilePath = $ImageFile.FullName
                Text = "[OCR 處理失敗: $ErrorOutput]"
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
Read-Host "按 Enter 鍵退出"
