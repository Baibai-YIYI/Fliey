//
//  AIService.swift
//  Fliey
//
//  Created by Cursor
//
//  功能说明：本模块封装对 Apple Intelligence 提供的 WritingTools API 的调用，支持文本摘要、翻译与语气改写。作为 SharedCore 模块的 AI 服务总线。
//

import Foundation

// 引入核心类型
import SharedCore // 导入 Operation 和 WritingTone 枚举

#if canImport(NaturalLanguage)
import NaturalLanguage
#endif

// 在iOS 18以上环境中导入WritingTools框架
@available(iOS 18.0, macOS 15.0, *)
import WritingTools

/// Fliey 错误类型定义
enum FlieyError: Error {
    case unsupportedDevice
    case invalidRequestParams
    case processingFailed(String)
}

/// Fliey 发给 AI 的请求参数封装体
struct AIRequest {
    let text: String                 // 输入文本
    let operation: Operation        // 操作类型
    let targetLang: String?         // 翻译目标语言（仅当 operation == .translate 时）
    let tone: WritingTone?          // 改写语气（仅当 operation == .rewrite 时）
    let sentenceLimit: Int?         // 摘要句数上限（仅当 operation == .summarize 时）
}

/// AI 处理结果统一返回结构
struct AIResponse {
    let text: String          // 处理后的文本
    let operation: Operation  // 原始请求的操作
    let duration: Double      // 处理耗时（秒）
    let rawOutput: String?    // 原始输出数据（JSON/Token数据等，仅用于调试）
    
    /// 可选的 Markdown 格式文本（如果支持）
    var markdownFormatted: String? = nil
}

/// 所有 AI 服务提供类必须遵守的协议
protocol AIServiceProtocol {
    func process(_ request: AIRequest) async -> Result<AIResponse, Error>
}

/*
⚙️ Apple WritingTools 接入设计（iOS 18+）：

调用结构示例：

  switch request.operation {
    case .summarize:
        let req = NSSummaryRequest(text: request.text, mode: .brief, maximumSentenceCount: request.sentenceLimit ?? 5)
        let result = try await req.summary
    case .translate:
        let req = NSTranslateRequest(sourceLanguage: "zh", targetLanguage: request.targetLang ?? "en")
        req.text = request.text
        let result = try await req.translation
    case .rewrite:
        let req = NSRewritingRequest(text: request.text, tone: .formal)
        let result = try await req.rewrittenText
  }

注意事项：
- 所有调用只能在 iOS/macOS 18+ 上运行；
- 返回值应包装为统一的 AIResponse；
- 错误应返回 Result.failure
*/

/// iOS 18+ 使用 WritingTools API 的默认实现
final class AIService: AIServiceProtocol {
    /// 处理 AI 请求并返回结果
    /// - Parameter request: AI 请求参数
    /// - Returns: AI 响应结果或错误
    /// - Note: 此实现仅支持 iOS 18+ / macOS 15+，在不支持的设备上会返回 unsupportedDevice 错误
    func process(_ request: AIRequest) async -> Result<AIResponse, Error> {
        // 检查设备是否支持 Apple Intelligence (iOS 18+)
        guard #available(iOS 18.0, macOS 15.0, *) else {
            return .failure(FlieyError.unsupportedDevice)
        }
        
        // 记录处理开始时间
        let startTime = CFAbsoluteTimeGetCurrent()
        
        do {
            // 根据操作类型，调用不同的 Apple Intelligence API
            switch request.operation {
            case .summarize:
                // 创建摘要请求
                let summaryRequest = NSSummaryRequest(
                    text: request.text,
                    mode: .brief,
                    maximumSentenceCount: request.sentenceLimit ?? 5
                )
                
                // 执行请求
                let summary = try await summaryRequest.summary
                
                // 计算处理时间
                let duration = CFAbsoluteTimeGetCurrent() - startTime
                
                // 返回结果
                return .success(AIResponse(
                    text: summary,
                    operation: .summarize,
                    duration: duration,
                    rawOutput: nil,
                    markdownFormatted: "## 摘要\n\n\(summary)"
                ))
                
            case .translate:
                // 验证目标语言
                guard let targetLang = request.targetLang, !targetLang.isEmpty else {
                    return .failure(FlieyError.invalidRequestParams)
                }
                
                // 创建翻译请求
                let translateRequest = NSTranslateRequest(
                    sourceLanguage: "zh", // 假设源语言是中文
                    targetLanguage: targetLang
                )
                translateRequest.text = request.text
                
                // 执行请求
                let translation = try await translateRequest.translation
                
                // 计算处理时间
                let duration = CFAbsoluteTimeGetCurrent() - startTime
                
                // 返回结果
                return .success(AIResponse(
                    text: translation,
                    operation: .translate,
                    duration: duration,
                    rawOutput: nil,
                    markdownFormatted: "## 翻译 (\(targetLang))\n\n\(translation)"
                ))
                
            case .rewrite:
                // 转换 Fliey 语气到系统 API 语气
                let systemTone = convertToSystemTone(request.tone ?? .formal)
                
                // 创建改写请求
                let rewriteRequest = NSRewritingRequest(
                    text: request.text,
                    tone: systemTone
                )
                
                // 执行请求
                let rewrittenText = try await rewriteRequest.rewrittenText
                
                // 计算处理时间
                let duration = CFAbsoluteTimeGetCurrent() - startTime
                
                // 返回结果
                let toneDescription = request.tone?.description ?? "正式"
                return .success(AIResponse(
                    text: rewrittenText,
                    operation: .rewrite,
                    duration: duration,
                    rawOutput: nil,
                    markdownFormatted: "## 改写 (语气: \(toneDescription))\n\n\(rewrittenText)"
                ))
            }
        } catch {
            return .failure(FlieyError.processingFailed(error.localizedDescription))
        }
    }
    
    /// 将 Fliey 内部语气转换为系统 API 支持的语气
    /// - Parameter tone: Fliey 内部定义的语气
    /// - Returns: 系统 API 支持的语气
    @available(iOS 18.0, macOS 15.0, *)
    private func convertToSystemTone(_ tone: WritingTone) -> NSRewritingRequest.Tone {
        switch tone {
        case .formal:
            return .formal
        case .casual:
            return .casual
        case .professional:
            return .professional
        case .concise:
            return .concise
        }
    }
}

/// 用于开发环境下模拟 AI 服务的实现类
final class FakeAIService: AIServiceProtocol {
    /// 处理 AI 请求并返回模拟结果
    /// - Parameter request: AI 请求参数
    /// - Returns: 模拟的 AI 响应结果
    func process(_ request: AIRequest) async -> Result<AIResponse, Error> {
        // 模拟处理延迟
        try? await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000))
        
        // 根据操作类型返回不同的模拟结果
        switch request.operation {
        case .summarize:
            let text = "这是一段自动生成的摘要内容。原文大约有 \(request.text.count) 个字符，已压缩为此摘要。"
            let markdown = """
            ## 文本摘要
            
            这是一段自动生成的**摘要内容**。原文大约有 \(request.text.count) 个字符，已压缩为此摘要。
            
            > 摘要基于原文主题，提取了关键信息
            """
            let rawOutput = """
            {
              "input_tokens": \(request.text.count / 4),
              "output_tokens": 30,
              "model": "fliey-summarizer-1.0",
              "truncated": false
            }
            """
            
            return .success(AIResponse(
                text: text,
                operation: .summarize,
                duration: 0.5,
                rawOutput: rawOutput,
                markdownFormatted: markdown
            ))
            
        case .translate:
            let targetLang = request.targetLang ?? "en"
            let text = "This is a translated text to \(targetLang). The original text has \(request.text.count) characters."
            let markdown = """
            ## 翻译结果 (\(targetLang))
            
            This is a **translated text** to \(targetLang). 
            The original text has \(request.text.count) characters.
            
            - 源语言: 中文
            - 目标语言: \(targetLang.uppercased())
            """
            let rawOutput = """
            {
              "source_lang": "zh",
              "target_lang": "\(targetLang)",
              "confidence": 0.92,
              "model": "fliey-translator-1.0"
            }
            """
            
            return .success(AIResponse(
                text: text,
                operation: .translate,
                duration: 0.7,
                rawOutput: rawOutput,
                markdownFormatted: markdown
            ))
            
        case .rewrite:
            let tone = request.tone?.description ?? "formal"
            let text = "这是以「\(tone)」语气改写后的文本。原文已根据要求调整了表达方式，但保留了核心内容。"
            let markdown = """
            ## 改写结果 (语气: \(tone))
            
            这是以「**\(tone)**」语气改写后的文本。
            
            原文已根据要求调整了表达方式，但保留了核心内容。
            
            *适用场景: 邮件、公文、演讲等*
            """
            let rawOutput = """
            {
              "tone": "\(tone)",
              "modified_level": "medium",
              "model": "fliey-rewriter-1.0"
            }
            """
            
            return .success(AIResponse(
                text: text,
                operation: .rewrite,
                duration: 0.6,
                rawOutput: rawOutput,
                markdownFormatted: markdown
            ))
        }
    }
}

// WritingTone 描述扩展
extension WritingTone {
    var description: String {
        switch self {
        case .formal: return "正式"
        case .casual: return "随意"
        case .professional: return "专业"
        case .concise: return "简洁"
        }
    }
}
