# PDF OCR 測試系統使用說明

## 資料夾結構
```
test_system/
├── input_pdfs/          # 放置要處理的 PDF 檔案
├── output_csv/          # OCR 結果 CSV 檔案輸出位置
├── temp_images/         # 臨時圖片檔案（自動清理）
├── pdf_ocr_to_csv.py    # Python 主程式
├── run_pdf_ocr.bat      # Windows 批次檔（簡化使用）
└── README.md            # 本說明檔

```

## 快速開始

### 方法一：使用批次檔（推薦）
1. 將 PDF 檔案放入 `input_pdfs/` 資料夾
2. 雙擊執行 `run_pdf_ocr.bat`
3. 等待處理完成
4. 在 `output_csv/` 資料夾中查看結果

### 方法二：使用 Python 腳本
```bash
# 安裝必要套件
pip install PyMuPDF Pillow

# 執行處理
python pdf_ocr_to_csv.py --input input_pdfs --output output_csv --language eng+chi_tra
```

## 參數說明

### 語言選項
- `eng`: 英文
- `chi_tra`: 繁體中文
- `chi_sim`: 簡體中文
- `eng+chi_tra`: 英文+繁體中文（預設）
- `eng+chi_sim`: 英文+簡體中文

### 命令列參數
```bash
python pdf_ocr_to_csv.py [選項]

選項:
  --input, -i      輸入 PDF 資料夾路徑（必須）
  --output, -o     輸出 CSV 資料夾路徑（必須）
  --language, -l   OCR 語言（預設: eng+chi_tra）
  --tesseract, -t  Tesseract 執行檔路徑
  --tessdata, -d   Tessdata 資料夾路徑
```

## 輸出格式

CSV 檔案包含以下欄位：
- `filename`: PDF 檔案名稱
- `page`: 頁碼
- `text`: OCR 識別的文字內容
- `timestamp`: 處理時間

## 系統需求

- Python 3.7+
- PyMuPDF (fitz)
- Pillow (PIL)
- 已編譯的 Tesseract

## 故障排除

### 常見問題
1. **找不到 Python**: 請安裝 Python 3.7 或更新版本
2. **套件安裝失敗**: 請確保網路連線正常，嘗試使用 `pip install --upgrade pip`
3. **OCR 品質不佳**: 可調整 PDF 轉圖片的解析度（修改 `mat = fitz.Matrix(2.0, 2.0)` 中的數值）
4. **中文識別問題**: 確認已正確下載中文語言檔案

### 提升 OCR 品質的建議
1. 使用高解析度的 PDF
2. 確保文字清晰，避免模糊或歪斜
3. 針對特定語言調整 `--language` 參數
4. 對於表格式內容，可考慮使用不同的 PSM 模式

## 範例

處理英文 PDF：
```bash
python pdf_ocr_to_csv.py -i input_pdfs -o output_csv -l eng
```

處理簡體中文 PDF：
```bash
python pdf_ocr_to_csv.py -i input_pdfs -o output_csv -l chi_sim
```

處理混合語言 PDF：
```bash
python pdf_ocr_to_csv.py -i input_pdfs -o output_csv -l eng+chi_tra+chi_sim
```
