//
//  DocumentParser.swift
//  Fliey
//
//  Created by Cursor
//
//  功能说明：将支持的文档（PDF、DOCX、TXT）解析为纯文本，供 AIService 进一步处理。
//  当前支持：
//    - PDF（使用 PDFKit 解析每页文本）
//    - DOCX（基于 ZIP 解包 + XML 解析正文）
//    - TXT（直接读取）
//  后续扩展：Markdown, HTML 等结构化文档
// 

protocol DocumentParserProtocol {
    /// 从给定文件路径中提取纯文本
    /// - Parameter filePath: 本地文件路径
    /// - Returns: 提取后的纯文本字符串
    func extractText(from filePath: String) throws -> String
}

// DocumentParser 会根据文件扩展名，自动选择以下子类：
//   - PDFParser: 使用 PDFKit 提取每一页文字，拼接为完整正文
//   - DOCXParser: 解析 Word 的 docx 文件（zip 解包，读取 word/document.xml）
//   - TXTParser: 直接读取 UTF‑8 字符串
//
// 主类负责根据扩展名调度，如：
//
//   let parser = DocumentParser()
//   let text = try parser.extractText(from: "/path/to/file.pdf") 