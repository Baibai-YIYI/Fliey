//
//  SharedResultBridge.swift
//  Fliey
//
//  Created by Cursor
//
//  功能说明：封装App Group共享数据的工具类，便于主App和Extension共享AI处理结果
//

import Foundation

/**
 * SharedResultBridge
 * 
 * 此工具类封装了在 Share Extension 和主应用之间共享 AI 处理结果的功能。
 * 使用 App Group 机制（UserDefaults）实现跨进程通信。
 * 
 * 主要用途:
 * - Share Extension 处理完成后，将结果保存到 App Group
 * - 主应用读取并显示 Share Extension 处理的结果
 * - 跨组件统一数据存取接口，避免重复代码
 */
struct SharedResultBridge {
    
    // MARK: - 常量
    
    /// App Group 标识符
    private static let appGroupIdentifier = "group.com.you.Fliey"
    
    /// 共享结果的 UserDefaults 键
    private static let resultKey = "latestResult"
    
    /// 是否有新结果的标志键
    private static let hasResultFlagKey = "hasSharedResult"
    
    // MARK: - 私有属性
    
    /// 共享 UserDefaults 实例
    private static var sharedDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupIdentifier)
    }
    
    // MARK: - 公共方法
    
    /**
     * 保存 AI 处理结果到 App Group
     * 
     * - Parameter result: 要保存的 AI 响应结果
     * - Returns: 保存是否成功
     */
    @discardableResult
    static func save(_ result: AIResponse) -> Bool {
        guard let defaults = sharedDefaults else {
            print("错误: 无法访问 App Group")
            return false
        }
        
        do {
            // 编码 AIResponse 为 Data
            let encoder = JSONEncoder()
            let resultData = try encoder.encode(result)
            
            // 保存数据和标志位
            defaults.set(resultData, forKey: resultKey)
            defaults.set(true, forKey: hasResultFlagKey)
            
            // iOS 12+ 会自动异步保存，无需调用 synchronize()
            
            print("成功: AI 结果已保存到 App Group")
            return true
        } catch {
            print("错误: 无法编码 AI 结果: \(error.localizedDescription)")
            return false
        }
    }
    
    /**
     * 从 App Group 加载最近的 AI 处理结果，并自动标记为已读
     * 
     * - Parameter autoMarkAsRead: 是否自动标记为已读，默认为 true
     * - Returns: AI 响应结果，如果没有或读取失败则返回 nil
     */
    static func load(autoMarkAsRead: Bool = true) -> AIResponse? {
        guard let defaults = sharedDefaults,
              defaults.bool(forKey: hasResultFlagKey),
              let resultData = defaults.data(forKey: resultKey) else {
            return nil
        }
        
        do {
            // 解码 Data 为 AIResponse
            let decoder = JSONDecoder()
            let result = try decoder.decode(AIResponse.self, from: resultData)
            
            // 自动标记为已读（如果需要）
            if autoMarkAsRead {
                markAsRead()
            }
            
            return result
        } catch {
            print("错误: 无法解码 AI 结果: \(error.localizedDescription)")
            markAsRead() // 出错时也标记为已读，避免重复尝试
            return nil
        }
    }
    
    /**
     * 标记共享结果为已读
     * 
     * - Note: 通常在成功加载并显示结果后调用
     */
    static func markAsRead() {
        sharedDefaults?.set(false, forKey: hasResultFlagKey)
        // iOS 12+ 会自动异步保存，无需调用 synchronize()
    }
    
    /**
     * 清除所有共享数据
     * 
     * - Returns: 清除是否成功
     */
    @discardableResult
    static func clear() -> Bool {
        guard let defaults = sharedDefaults else {
            return false
        }
        
        defaults.removeObject(forKey: resultKey)
        defaults.set(false, forKey: hasResultFlagKey)
        // iOS 12+ 会自动异步保存，无需调用 synchronize()
        
        return true
    }
    
    /**
     * 检查是否有新的共享结果
     * 
     * - Returns: 是否有新结果
     */
    static func hasNewResult() -> Bool {
        return sharedDefaults?.bool(forKey: hasResultFlagKey) ?? false
    }
} 