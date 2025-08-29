@echo off
chcp 65001 >nul
echo 啟動 OCR 測試系統...
echo.

REM 執行 PowerShell 腳本
powershell -ExecutionPolicy Bypass -File "simple_ocr_test.ps1"

pause
