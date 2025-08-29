README - 測試圖片說明

目前系統已建立完成，包含以下功能：

## 測試系統結構
```
test_system/
├── input_pdfs/              # 放置 PDF 檔案（暫時用 input_images）
├── input_images/            # 放置測試圖片（JPG, PNG, BMP, TIFF, GIF）
├── output_csv/              # OCR 結果輸出
├── temp_images/             # 臨時檔案
├── simple_ocr_test.ps1      # PowerShell 測試腳本
├── run_simple_test.bat      # 簡易執行批次檔
├── pdf_ocr_to_csv.py        # Python 完整版（需要安裝 Python 套件）
└── README.md                # 說明文件
```

## 快速測試步驟：

### 第1步：準備測試圖片
1. 建立一些包含文字的圖片檔案
2. 放入 `input_images/` 資料夾
3. 支援格式：JPG, PNG, BMP, TIFF, GIF

### 第2步：執行測試
- 雙擊 `run_simple_test.bat`
- 或在 PowerShell 中執行：`.\simple_ocr_test.ps1`

### 第3步：查看結果
- 結果會儲存在 `output_csv/` 資料夾
- CSV 檔案包含：檔案名稱、文字內容、時間戳記

## 支援的語言：
- 英文：eng
- 繁體中文：chi_tra  
- 簡體中文：chi_sim
- 混合：eng+chi_tra（預設）

## 範例測試圖片建議：
1. 螢幕截圖（包含文字）
2. 文件掃描圖
3. 書本照片
4. 手寫文字圖片（識別率較低）

系統已準備就緒，可以開始測試！
