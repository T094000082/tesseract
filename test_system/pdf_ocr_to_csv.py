#!/usr/bin/env python3
"""
PDF OCR to CSV Converter
將 PDF 檔案轉換為圖片，使用 Tesseract 進行 OCR，然後輸出到 CSV 檔案
"""

import os
import csv
import sys
import subprocess
from pathlib import Path
import fitz  # PyMuPDF
from PIL import Image
import argparse
from datetime import datetime

class PDFOCRProcessor:
    def __init__(self, tesseract_path, tessdata_path):
        self.tesseract_path = tesseract_path
        self.tessdata_path = tessdata_path
        self.temp_dir = Path("temp_images")
        self.temp_dir.mkdir(exist_ok=True)
        
    def pdf_to_images(self, pdf_path):
        """將 PDF 轉換為圖片"""
        images = []
        try:
            doc = fitz.open(pdf_path)
            for page_num in range(len(doc)):
                page = doc.load_page(page_num)
                # 設定較高的解析度以提升 OCR 品質
                mat = fitz.Matrix(2.0, 2.0)  # 2x zoom
                pix = page.get_pixmap(matrix=mat)
                
                img_path = self.temp_dir / f"{Path(pdf_path).stem}_page_{page_num + 1}.png"
                pix.save(str(img_path))
                images.append((img_path, page_num + 1))
                
            doc.close()
            return images
        except Exception as e:
            print(f"PDF 轉換錯誤: {e}")
            return []
    
    def ocr_image(self, image_path, language="eng+chi_tra"):
        """對圖片進行 OCR"""
        try:
            # 設定環境變數
            env = os.environ.copy()
            env['TESSDATA_PREFIX'] = self.tessdata_path
            
            # 執行 Tesseract OCR
            cmd = [
                self.tesseract_path,
                str(image_path),
                "stdout",
                "-l", language,
                "--psm", "6",  # 假設單一均勻文字區塊
                "-c", "preserve_interword_spaces=1"
            ]
            
            result = subprocess.run(cmd, capture_output=True, text=True, encoding='utf-8', env=env)
            
            if result.returncode == 0:
                return result.stdout.strip()
            else:
                print(f"OCR 錯誤: {result.stderr}")
                return ""
                
        except Exception as e:
            print(f"OCR 處理錯誤: {e}")
            return ""
    
    def process_pdf(self, pdf_path, language="eng+chi_tra"):
        """處理單一 PDF 檔案"""
        print(f"處理 PDF: {pdf_path}")
        
        # 轉換 PDF 為圖片
        images = self.pdf_to_images(pdf_path)
        if not images:
            return []
        
        results = []
        for img_path, page_num in images:
            print(f"  處理第 {page_num} 頁...")
            ocr_text = self.ocr_image(img_path, language)
            
            results.append({
                'filename': Path(pdf_path).name,
                'page': page_num,
                'text': ocr_text,
                'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            })
            
            # 清理臨時圖片
            try:
                os.remove(img_path)
            except:
                pass
                
        return results
    
    def save_to_csv(self, results, output_path):
        """將結果儲存到 CSV"""
        try:
            with open(output_path, 'w', newline='', encoding='utf-8-sig') as csvfile:
                fieldnames = ['filename', 'page', 'text', 'timestamp']
                writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
                
                writer.writeheader()
                for row in results:
                    writer.writerow(row)
                    
            print(f"結果已儲存到: {output_path}")
            return True
        except Exception as e:
            print(f"CSV 儲存錯誤: {e}")
            return False
    
    def process_folder(self, input_folder, output_folder, language="eng+chi_tra"):
        """處理整個資料夾的 PDF 檔案"""
        input_path = Path(input_folder)
        output_path = Path(output_folder)
        output_path.mkdir(exist_ok=True)
        
        pdf_files = list(input_path.glob("*.pdf"))
        if not pdf_files:
            print(f"在 {input_folder} 中沒有找到 PDF 檔案")
            return
        
        all_results = []
        
        for pdf_file in pdf_files:
            results = self.process_pdf(pdf_file, language)
            all_results.extend(results)
        
        # 儲存所有結果到一個 CSV
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        csv_filename = f"ocr_results_{timestamp}.csv"
        csv_path = output_path / csv_filename
        
        self.save_to_csv(all_results, csv_path)
        
        # 也為每個 PDF 建立個別的 CSV
        for pdf_file in pdf_files:
            pdf_results = [r for r in all_results if r['filename'] == pdf_file.name]
            if pdf_results:
                individual_csv = output_path / f"{pdf_file.stem}_ocr_{timestamp}.csv"
                self.save_to_csv(pdf_results, individual_csv)

def main():
    parser = argparse.ArgumentParser(description='PDF OCR to CSV Converter')
    parser.add_argument('--input', '-i', required=True, help='輸入 PDF 資料夾路徑')
    parser.add_argument('--output', '-o', required=True, help='輸出 CSV 資料夾路徑')
    parser.add_argument('--language', '-l', default='eng+chi_tra', help='OCR 語言 (預設: eng+chi_tra)')
    parser.add_argument('--tesseract', '-t', 
                       default=r'D:\Leo\VScode\tesseract\build\bin\Release\tesseract.exe',
                       help='Tesseract 執行檔路徑')
    parser.add_argument('--tessdata', '-d',
                       default=r'D:\Leo\VScode\tesseract\tessdata',
                       help='Tessdata 資料夾路徑')
    
    args = parser.parse_args()
    
    # 檢查 Tesseract 是否存在
    if not os.path.exists(args.tesseract):
        print(f"錯誤: 找不到 Tesseract 執行檔: {args.tesseract}")
        return 1
    
    # 檢查 tessdata 是否存在
    if not os.path.exists(args.tessdata):
        print(f"錯誤: 找不到 tessdata 資料夾: {args.tessdata}")
        return 1
    
    # 建立處理器
    processor = PDFOCRProcessor(args.tesseract, args.tessdata)
    
    # 處理資料夾
    processor.process_folder(args.input, args.output, args.language)
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
