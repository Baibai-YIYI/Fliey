//
//  MainViewModel.swift
//  Fliey
//
//  Created by Cursor
//
//  功能说明：管理主界面的状态，处理用户交互，协调数据流
//

import Foundation
import Combine
import SharedCore // 导入共享类型和桥接工具

// 注意：Codable 扩展已移至 SharedCore/Extensions/Operation+Codable.swift
// 共享 AIResponse 和 Operation 类型的编解码逻辑

/// 文档处理状态
enum ProcessingState {
    case idle             // 空闲，可以接受新任务
    case parsing          // 文档解析中
    case processing       // AI 处理中
    case complete         // 处理完成
    case error(String)    // 处理出错，带错误信息
}

/// 历史记录项模型
struct HistoryItem: Identifiable {
    let id: UUID
    let fileName: String
    let operation: Operation
    let timestamp: Date
    let resultPreview: String
    var isFavorite: Bool
    
    /// 用于去重比较的唯一标识
    /// 使用文件名+操作类型+时间戳的日期部分（不含时分秒）生成
    var uniqueIdentifier: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: timestamp)
        return "\(fileName)_\(operation)_\(dateString)"
    }
}

/**
 * 主界面视图模型，负责管理应用状态和业务逻辑
 *
 * 主要职责：
 * 1. 管理界面状态（加载中/空闲/处理中/错误等）
 * 2. 处理用户交互事件（文件导入、操作选择等）
 * 3. 与 AIService 交互，发起和接收 AI 处理请求
 * 4. 管理历史记录和处理结果缓存
 * 5. 持久化用户偏好设置
 */
class MainViewModel: ObservableObject {
    // MARK: - 已发布状态属性
    
    /// 当前文档处理状态
    @Published var state: ProcessingState = .idle
    
    /// 历史记录列表
    @Published var historyItems: [HistoryItem] = []
    
    /// 是否正在加载历史记录
    @Published var isLoadingHistory: Bool = false
    
    /// 当前选中的操作类型
    @Published var selectedOperation: Operation = .summarize
    
    /// 翻译目标语言
    @Published var targetLanguage: String = "en"
    
    /// 改写语气
    @Published var writingTone: WritingTone = .formal
    
    /// 摘要句数上限
    @Published var summaryLimit: Int = 3
    
    /// 当前处理结果
    @Published var currentResult: AIResponse?
    
    // MARK: - 私有属性
    
    /// AI 服务实例
    private var aiService: AIServiceProtocol
    
    /// 文档解析器实例
    private var documentParser: DocumentParserProtocol
    
    /// 取消订阅包
    private var cancellables = Set<AnyCancellable>()
    
    /// 历史记录保留天数
    private let historyRetentionDays: Int = 7
    
    /// 最近处理的唯一标识，用于防止短时间内重复保存相同记录
    private var recentlyProcessedIdentifiers = Set<String>()
    
    // MARK: - 初始化方法
    
    /**
     * 创建主视图模型
     * - Parameters:
     *   - aiService: AI 服务实例，默认使用模拟服务
     *   - documentParser: 文档解析器实例
     */
    init(aiService: AIServiceProtocol = FakeAIService(),
         documentParser: DocumentParserProtocol) {
        self.aiService = aiService
        self.documentParser = documentParser
        
        // 加载历史记录
        loadHistoryItems()
        
        // 检查是否有 Share Extension 共享的结果
        loadSharedResultIfAvailable()
    }
    
    // MARK: - 业务方法
    
    /**
     * 导入文件并处理
     * - Parameters:
     *   - url: 文件 URL
     */
    func importFile(from url: URL) {
        /* 
         实现步骤：
         1. 更新状态为 .parsing
         2. 使用 documentParser 解析文件
         3. 解析完成后，构建 AIRequest
         4. 更新状态为 .processing
         5. 调用 aiService.process 处理请求
         6. 处理完成后，更新状态为 .complete 或 .error
         7. 保存结果到历史记录
         */
    }
    
    /**
     * 处理文本
     * - Parameters:
     *   - text: 输入文本
     */
    func processText(_ text: String) {
        // NOTE: Day 7 使用 FakeAIService，待真机测试时替换为 AIService()
        
        /*
         实现步骤：
         1. 更新状态为 .processing
         2. 构建 AIRequest
         3. 调用 aiService.process 处理请求
         4. 处理完成后，更新状态为 .complete 或 .error
         5. 保存结果到历史记录
         */
        
        // Step 0: 如果 selectedOperation == .summarize，则直接填充 FakeAIService 返回值到 currentResult
        if selectedOperation == .summarize {
            // 使用 FakeAIService 生成的结果
            let fakeResult = FakeAIService().generateFakeResponse(for: text, operation: .summarize)
            currentResult = fakeResult
            state = .complete
            
            // 保存到历史记录
            if let result = currentResult {
                saveToHistory(result: result, fileName: "示例文本.txt")
            }
            return
        }
        
        // 其他操作逻辑...
    }
    
    /**
     * 加载历史记录
     */
    private func loadHistoryItems() {
        /*
         实现步骤：
         1. 更新 isLoadingHistory 为 true
         2. 从本地存储加载历史记录
         3. 更新 historyItems
         4. 更新 isLoadingHistory 为 false
         5. 清理过期记录（超过 historyRetentionDays 天的记录）
         
         历史记录缓存失效逻辑：
         - 默认保留最近 7 天的历史记录
         - 标记为收藏的记录不会过期
         - 过期的记录将从列表和磁盘中删除
         - 可通过设置调整保留天数（historyRetentionDays）
         */
        
        // 清理过期记录的示例代码
        cleanupExpiredRecords()
    }
    
    /**
     * 清理过期的历史记录
     */
    private func cleanupExpiredRecords() {
        let calendar = Calendar.current
        let expirationDate = calendar.date(byAdding: .day, value: -historyRetentionDays, to: Date())!
        
        // 过滤掉过期且未收藏的记录
        historyItems = historyItems.filter { item in
            item.isFavorite || calendar.compare(item.timestamp, to: expirationDate, toGranularity: .day) == .orderedDescending
        }
        
        // TODO: 同步删除磁盘上的过期记录
    }
    
    /**
     * 保存结果到历史记录
     * - Parameters:
     *   - result: AI 处理结果
     *   - fileName: 文件名（可选）
     */
    private func saveToHistory(result: AIResponse, fileName: String? = nil) {
        /*
         实现步骤：
         1. 创建新的 HistoryItem
         2. 检查是否为重复记录（同一文件、同一操作、同一天）
         3. 如非重复记录，则更新 historyItems
         4. 持久化历史记录
         
         防重复保存逻辑：
         - 生成 uniqueIdentifier（文件名+操作类型+日期）
         - 检查是否在 recentlyProcessedIdentifiers 集合中
         - 将新记录的标识加入集合，并设置 30 分钟后自动移除
         - 定期清理 recentlyProcessedIdentifiers 集合
         */
        
        // 创建新的历史记录项
        let newItem = HistoryItem(
            id: UUID(),
            fileName: fileName ?? "文本片段",
            operation: result.operation,
            timestamp: Date(),
            resultPreview: String(result.text.prefix(100)),
            isFavorite: false
        )
        
        // 去重逻辑
        if !isDuplicateRecord(newItem) {
            historyItems.insert(newItem, at: 0)
            saveHistoryToDisk()
            
            // 记录此次处理的唯一标识，防止短时间内重复保存
            markAsRecentlyProcessed(newItem.uniqueIdentifier)
        }
    }
    
    /**
     * 检查是否为重复记录
     */
    private func isDuplicateRecord(_ item: HistoryItem) -> Bool {
        return recentlyProcessedIdentifiers.contains(item.uniqueIdentifier)
    }
    
    /**
     * 标记为最近处理过的记录，并设置定时移除
     */
    private func markAsRecentlyProcessed(_ identifier: String) {
        recentlyProcessedIdentifiers.insert(identifier)
        
        // 30分钟后自动从去重集合中移除
        DispatchQueue.main.asyncAfter(deadline: .now() + 1800) { [weak self] in
            self?.recentlyProcessedIdentifiers.remove(identifier)
        }
    }
    
    /**
     * 保存历史记录到磁盘
     */
    private func saveHistoryToDisk() {
        // TODO: 实现历史记录持久化
    }
    
    /**
     * 从 App Group 加载 Share Extension 共享的 AI 处理结果
     * 
     * 此方法应在以下时机调用:
     * - 应用启动时
     * - 应用从后台回到前台时
     * - 用户手动刷新界面时
     */
    func loadSharedResultIfAvailable() {
        // 使用 SharedResultBridge 加载共享结果
        if let sharedResult = SharedResultBridge.load() {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                // 更新当前处理结果
                self.currentResult = sharedResult
                
                // 更新状态为完成
                self.state = .complete
                
                // 保存到历史记录
                self.saveToHistory(result: sharedResult, fileName: "从分享扩展处理")
            }
            
            print("成功: 从 App Group 读取到共享 AI 结果")
        }
    }
    
    /**
     * 在应用回到前台时调用此方法，检查是否有新的共享结果
     */
    func applicationWillEnterForeground() {
        loadSharedResultIfAvailable()
    }
} 