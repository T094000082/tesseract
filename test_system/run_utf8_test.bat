@echo off
chcp 65001 >nul
echo ================================================
echo      Tesseract OCR 測試系統 (UTF-8 支援)
echo ================================================
echo.

REM 執行 PowerShell 腳本處理 UTF-8 編碼
powershell -ExecutionPolicy Bypass -File "utf8_ocr_test.ps1"

pause
