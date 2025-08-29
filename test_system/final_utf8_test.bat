@echo off
chcp 65001 >nul

set TESSERACT=D:\Leo\VScode\tesseract\build\bin\Release\tesseract.exe
set TESSDATA_PREFIX=D:\Leo\VScode\tesseract\tessdata

if not exist input_images mkdir input_images
if not exist output_csv mkdir output_csv

echo ================================================
echo            OCR Test System (UTF-8)
echo ================================================

set /a count=0
for %%f in (input_images\*.jpg input_images\*.png input_images\*.bmp input_images\*.gif input_images\*.tiff) do (
    if exist "%%f" set /a count+=1
)

if %count%==0 (
    echo No image files found. Please put images in input_images folder.
    pause
    exit /b 0
)

echo Found %count% image files
echo.

REM Create CSV with timestamp
for /f "tokens=2-8 delims=/:. " %%a in ("%date% %time%") do set timestamp=%%c%%a%%b_%%d%%e%%f
set csvfile=output_csv\ocr_results_%timestamp%.csv

REM Create CSV header using echo with UTF-8
echo FileName,Text,Timestamp > "%csvfile%"

echo Processing images...
echo.

for %%f in (input_images\*.jpg input_images\*.png input_images\*.bmp input_images\*.gif input_images\*.tiff) do (
    if exist "%%f" (
        echo Processing: %%~nxf
        
        "%TESSERACT%" "%%f" tempocr -l eng+chi_tra --psm 6 >nul 2>&1
        
        if exist tempocr.txt (
            echo %%~nxf processed successfully
            REM Use PowerShell to handle UTF-8 properly
            powershell -Command "$text=[IO.File]::ReadAllText('tempocr.txt',[Text.Encoding]::UTF8).Replace('\"','\"\"').Replace(\"`r`n\",' ').Replace(\"`n\",' '); Add-Content '%csvfile%' ('\"%%~nxf\",\"'+$text+'\",\"'+(Get-Date -f 'yyyy-MM-dd HH:mm:ss')+'\"') -Encoding UTF8"
            del tempocr.txt
        ) else (
            echo %%~nxf failed
            echo "%%~nxf","[Failed]","%date% %time%" >> "%csvfile%"
        )
    )
)

echo.
echo ================================================
echo             Complete!
echo ================================================
echo Results saved to: %csvfile%
echo.
echo To view Chinese correctly:
echo - Open with VS Code or Notepad++
echo - In Excel: Data ^> Get Data ^> From Text/CSV ^> UTF-8
echo.
pause
