//
//  ShareViewModel.swift
//  Fliey
//
//  Created by Cursor
//
//  功能说明：管理Share Extension的数据和业务逻辑，与SharedCore交互
//

import Foundation
import UIKit
import SwiftUI
import SharedCore // 导入共享类型和桥接工具

/**
 * ShareViewModel 是 Share Extension 的核心，负责：
 * 1. 接收系统分享的内容（文本或文件）
 * 2. 调用 DocumentParser 解析文件（如果分享的是文件）
 * 3. 调用 AIService 处理文本
 * 4. 将处理结果保存到共享存储区（UserDefaults）
 */
class ShareViewModel: ObservableObject {
    // MARK: - 发布属性
    
    /// 处理状态
    @Published var state: ProcessingState = .idle
    
    /// 处理结果
    @Published var result: AIResponse?
    
    /// 输入文本
    @Published var inputText: String = ""
    
    /// 输入文件URL
    @Published var fileURL: URL?
    
    /// 选择的操作类型
    @Published var operation: Operation = .summarize
    
    /// 翻译目标语言
    @Published var targetLanguage: String = "en"
    
    /// 改写语气
    @Published var writingTone: WritingTone = .formal
    
    // MARK: - 私有属性
    
    /// AI 服务实例
    private let aiService: AIServiceProtocol
    
    /// 文档解析器
    private let documentParser: DocumentParserProtocol
    
    // MARK: - 初始化
    
    /**
     * 创建 Share Extension 视图模型
     * - Parameters:
     *   - aiService: AI 服务实例
     *   - documentParser: 文档解析器实例
     */
    init(aiService: AIServiceProtocol, documentParser: DocumentParserProtocol) {
        self.aiService = aiService
        self.documentParser = documentParser
    }
    
    // MARK: - 公开方法
    
    /**
     * 处理分享的文本内容
     * - Parameter text: 分享的文本
     */
    func processSharedText(_ text: String) async {
        /*
         实现步骤：
         1. 更新 inputText
         2. 更新状态为 .processing
         3. 构建 AIRequest
         4. 调用 aiService.process
         5. 处理完成后更新状态和结果
         6. 保存结果到共享存储区
         */
    }
    
    /**
     * 处理分享的文件
     * - Parameter url: 文件 URL
     */
    func processSharedFile(at url: URL) async {
        /*
         实现步骤：
         1. 更新 fileURL
         2. 更新状态为 .parsing
         3. 使用 documentParser 解析文件
         4. 解析完成后，调用 processSharedText 处理解析出的文本
         */
    }
    
    /**
     * 保存结果到共享存储区
     * - Parameter result: AI 处理结果
     */
    private func saveToSharedDefaults(_ result: AIResponse) {
        // 使用 SharedResultBridge 保存结果
        if SharedResultBridge.save(result) {
            print("成功: AI 结果已保存到 App Group 共享存储")
        } else {
            print("错误: 无法保存 AI 结果到 App Group")
        }
    }
}

/// 处理状态枚举
enum ProcessingState {
    case idle          // 空闲
    case parsing       // 解析文件中
    case processing    // AI 处理中
    case complete      // 处理完成
    case error(String) // 错误
} 