//
//  PDFParser.swift
//  Fliey
//
//  Created by Cursor
//
//  功能说明：使用 PDFKit 分页读取 PDF 文件内容，将其拼接为纯文本。
//  实现 DocumentParserProtocol 接口。
// 

import Foundation
import PDFKit

/// PDF文档解析器
class PDFParser: DocumentParserProtocol {
    /// 从PDF文件中提取文本
    /// - Parameter filePath: PDF文件路径
    /// - Returns: 提取的文本内容
    func extractText(from filePath: String) throws -> String {
        // 创建文件URL
        let fileURL = URL(fileURLWithPath: filePath)
        
        // 检查文件是否存在
        guard FileManager.default.fileExists(atPath: filePath) else {
            throw NSError(domain: "PDFParserError", code: 404, userInfo: [NSLocalizedDescriptionKey: "文件不存在: \(filePath)"])
        }
        
        // 创建PDF文档
        guard let pdfDocument = PDFDocument(url: fileURL) else {
            throw NSError(domain: "PDFParserError", code: 500, userInfo: [NSLocalizedDescriptionKey: "无法加载PDF文档: \(filePath)"])
        }
        
        // 提取文本
        let textBuilder = NSMutableString()
        
        // 遍历所有页面
        for pageIndex in 0..<pdfDocument.pageCount {
            if let page = pdfDocument.page(at: pageIndex) {
                if let pageText = page.string {
                    textBuilder.append(pageText)
                    // 添加页面分隔符
                    if pageIndex < pdfDocument.pageCount - 1 {
                        textBuilder.append("\n\n")
                    }
                }
            }
        }
        
        return textBuilder as String
    }
} 