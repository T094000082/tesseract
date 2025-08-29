@echo off
chcp 65001 >nul
echo ================================================
echo           PDF OCR 轉 CSV 系統
echo ================================================
echo.

REM 設定路徑
set TESSERACT_PATH=D:\Leo\VScode\tesseract\build\bin\Release\tesseract.exe
set TESSDATA_PATH=D:\Leo\VScode\tesseract\tessdata
set INPUT_FOLDER=D:\Leo\VScode\tesseract\test_system\input_pdfs
set OUTPUT_FOLDER=D:\Leo\VScode\tesseract\test_system\output_csv

echo 設定資訊:
echo - Tesseract 路徑: %TESSERACT_PATH%
echo - 語言資料路徑: %TESSDATA_PATH%
echo - 輸入資料夾: %INPUT_FOLDER%
echo - 輸出資料夾: %OUTPUT_FOLDER%
echo.

REM 檢查 Python 是否安裝
python --version >nul 2>&1
if errorlevel 1 (
    echo 錯誤: 未找到 Python，請先安裝 Python
    pause
    exit /b 1
)

REM 檢查必要的 Python 套件
echo 檢查 Python 套件...
python -c "import fitz, PIL, csv, subprocess" >nul 2>&1
if errorlevel 1 (
    echo 正在安裝必要的 Python 套件...
    pip install PyMuPDF Pillow
    if errorlevel 1 (
        echo 錯誤: Python 套件安裝失敗
        pause
        exit /b 1
    )
)

REM 檢查輸入資料夾是否有 PDF 檔案
if not exist "%INPUT_FOLDER%\*.pdf" (
    echo.
    echo 注意: 在 %INPUT_FOLDER% 中沒有找到 PDF 檔案
    echo 請將要處理的 PDF 檔案放入此資料夾
    echo.
    pause
    exit /b 0
)

echo.
echo 開始處理 PDF 檔案...
echo.

REM 執行 Python 腳本
python pdf_ocr_to_csv.py --input "%INPUT_FOLDER%" --output "%OUTPUT_FOLDER%" --language eng+chi_tra

if errorlevel 1 (
    echo.
    echo 處理過程中發生錯誤
) else (
    echo.
    echo ================================================
    echo             處理完成！
    echo ================================================
    echo.
    echo 請檢查輸出資料夾: %OUTPUT_FOLDER%
    echo.
)

pause
