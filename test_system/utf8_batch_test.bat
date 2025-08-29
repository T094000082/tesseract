@echo off
chcp 65001 >nul

set TESSERACT_PATH=D:\Leo\VScode\tesseract\build\bin\Release\tesseract.exe
set TESSDATA_PREFIX=D:\Leo\VScode\tesseract\tessdata
set INPUT_FOLDER=input_images
set OUTPUT_FOLDER=output_csv

if not exist "%INPUT_FOLDER%" mkdir "%INPUT_FOLDER%"
if not exist "%OUTPUT_FOLDER%" mkdir "%OUTPUT_FOLDER%"

echo ================================================
echo            OCR UTF-8 Test System
echo ================================================
echo.

REM 計算檔案數量
set FILE_COUNT=0
for %%f in ("%INPUT_FOLDER%\*.jpg" "%INPUT_FOLDER%\*.png" "%INPUT_FOLDER%\*.bmp" "%INPUT_FOLDER%\*.gif" "%INPUT_FOLDER%\*.tiff") do (
    if exist "%%f" set /a FILE_COUNT+=1
)

if %FILE_COUNT%==0 (
    echo No image files found in %INPUT_FOLDER%
    echo Please put image files in %INPUT_FOLDER% folder
    echo Supported formats: JPG, PNG, BMP, GIF, TIFF
    pause
    exit /b 0
)

echo Found %FILE_COUNT% image files
echo.

REM 建立 CSV 檔案
set TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set CSV_FILE=%OUTPUT_FOLDER%\ocr_results_utf8_%TIMESTAMP%.csv

REM 使用 PowerShell 建立 UTF-8 CSV 標題
powershell -Command "[System.IO.File]::WriteAllText('%CSV_FILE%', 'FileName,Text,Timestamp' + [Environment]::NewLine, [System.Text.Encoding]::UTF8)"

echo Processing images...
echo.

REM 處理每個圖片檔案
for %%f in ("%INPUT_FOLDER%\*.jpg" "%INPUT_FOLDER%\*.png" "%INPUT_FOLDER%\*.bmp" "%INPUT_FOLDER%\*.gif" "%INPUT_FOLDER%\*.tiff") do (
    if exist "%%f" (
        echo Processing: %%~nxf
        
        REM 執行 OCR
        "%TESSERACT_PATH%" "%%f" temp_ocr_output -l eng+chi_tra --psm 6 2>nul
        
        if exist temp_ocr_output.txt (
            REM 使用 PowerShell 處理 UTF-8 編碼
            powershell -Command "$content = [System.IO.File]::ReadAllText('temp_ocr_output.txt', [System.Text.Encoding]::UTF8); $content = $content -replace '\"', '\"\"' -replace \"`r`n\", ' ' -replace \"`n\", ' '; $line = '\"%%~nxf\",\"' + $content + '\",\"' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + '\"' + [Environment]::NewLine; [System.IO.File]::AppendAllText('%CSV_FILE%', $line, [System.Text.Encoding]::UTF8)"
            del temp_ocr_output.txt 2>nul
            echo   Success
        ) else (
            powershell -Command "$line = '\"%%~nxf\",\"[OCR Failed]\",\"' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + '\"' + [Environment]::NewLine; [System.IO.File]::AppendAllText('%CSV_FILE%', $line, [System.Text.Encoding]::UTF8)"
            echo   Failed
        )
        echo.
    )
)

echo ================================================
echo             Processing Complete!
echo ================================================
echo.
echo Results saved to: %CSV_FILE%
echo The CSV file uses UTF-8 encoding for proper Chinese display.
echo.
echo To view Chinese text properly:
echo 1. Open the CSV file with Excel
echo 2. Or use a text editor that supports UTF-8 (like VS Code)
echo.
pause
