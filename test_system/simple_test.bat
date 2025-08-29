@echo off
chcp 65001 >nul
echo ================================================
echo           Tesseract OCR 測試系統
echo ================================================
echo.

REM 設定路徑
set TESSERACT_PATH=D:\Leo\VScode\tesseract\build\bin\Release\tesseract.exe
set TESSDATA_PREFIX=D:\Leo\VScode\tesseract\tessdata
set INPUT_FOLDER=input_images
set OUTPUT_FOLDER=output_csv

REM 檢查 Tesseract
if not exist "%TESSERACT_PATH%" (
    echo 錯誤: 找不到 Tesseract 執行檔
    pause
    exit /b 1
)

REM 檢查 tessdata
if not exist "%TESSDATA_PREFIX%" (
    echo 錯誤: 找不到 tessdata 資料夾
    pause
    exit /b 1
)

REM 建立必要資料夾
if not exist "%INPUT_FOLDER%" mkdir "%INPUT_FOLDER%"
if not exist "%OUTPUT_FOLDER%" mkdir "%OUTPUT_FOLDER%"

echo 設定資訊:
echo - Tesseract: %TESSERACT_PATH%
echo - 語言資料: %TESSDATA_PREFIX%
echo - 輸入資料夾: %INPUT_FOLDER%
echo - 輸出資料夾: %OUTPUT_FOLDER%
echo.

REM 檢查輸入檔案
set FILE_COUNT=0
for %%f in ("%INPUT_FOLDER%\*.jpg" "%INPUT_FOLDER%\*.jpeg" "%INPUT_FOLDER%\*.png" "%INPUT_FOLDER%\*.bmp" "%INPUT_FOLDER%\*.tiff" "%INPUT_FOLDER%\*.gif") do (
    if exist "%%f" set /a FILE_COUNT+=1
)

if %FILE_COUNT%==0 (
    echo 注意: 在 %INPUT_FOLDER% 中沒有找到圖片檔案
    echo 支援的格式: JPG, PNG, BMP, TIFF, GIF
    echo 請將圖片檔案放入 %INPUT_FOLDER% 資料夾中
    echo.
    pause
    exit /b 0
)

echo 找到 %FILE_COUNT% 個圖片檔案
echo.

REM 建立 CSV 標題
set TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set CSV_FILE=%OUTPUT_FOLDER%\ocr_results_%TIMESTAMP%.csv

REM 使用 PowerShell 建立 UTF-8 編碼的 CSV 標題
powershell -Command "& {[System.IO.File]::WriteAllText('%CSV_FILE%', 'FileName,Text,Timestamp' + [Environment]::NewLine, [System.Text.Encoding]::UTF8)}"

REM 處理圖片檔案
echo 開始處理圖片檔案...
echo.

for %%f in ("%INPUT_FOLDER%\*.jpg" "%INPUT_FOLDER%\*.jpeg" "%INPUT_FOLDER%\*.png" "%INPUT_FOLDER%\*.bmp" "%INPUT_FOLDER%\*.tiff" "%INPUT_FOLDER%\*.gif") do (
    if exist "%%f" (
        echo 處理: %%~nxf
        
        REM 執行 OCR 並將結果儲存到臨時檔案
        "%TESSERACT_PATH%" "%%f" temp_ocr_output -l eng+chi_tra --psm 6 2>nul
        
        if exist temp_ocr_output.txt (
            REM 使用 PowerShell 讀取 OCR 結果並以 UTF-8 格式寫入 CSV
            powershell -Command "& {$content = [System.IO.File]::ReadAllText('temp_ocr_output.txt', [System.Text.Encoding]::UTF8); $content = $content -replace '\"', '\"\"' -replace '`r`n', ' ' -replace '`n', ' '; $line = '\"%%~nxf\",\"' + $content + '\",\"%date% %time%\"' + [Environment]::NewLine; [System.IO.File]::AppendAllText('%CSV_FILE%', $line, [System.Text.Encoding]::UTF8)}"
            del temp_ocr_output.txt 2>nul
            echo   成功
        ) else (
            REM 使用 PowerShell 寫入錯誤訊息
            powershell -Command "& {$line = '\"%%~nxf\",\"[OCR 處理失敗]\",\"%date% %time%\"' + [Environment]::NewLine; [System.IO.File]::AppendAllText('%CSV_FILE%', $line, [System.Text.Encoding]::UTF8)}"
            echo   失敗
        )
        echo.
    )
)

echo ================================================
echo             處理完成！
echo ================================================
echo.
echo 結果已儲存到: %CSV_FILE%
echo.
pause
