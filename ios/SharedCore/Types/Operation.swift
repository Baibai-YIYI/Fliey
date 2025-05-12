//
//  Operation.swift
//  Fliey
//
//  Created by Cursor
//
//  功能说明：定义Fliey应用的核心操作类型和语气枚举
//

import Foundation

/// 支持的 AI 操作类型
public enum Operation {
    case summarize
    case translate
    case rewrite
}

/// 支持的文本改写语气
public enum WritingTone {
    case formal
    case casual
    case professional
    case concise
}

// WritingTone 描述扩展
extension WritingTone {
    public var description: String {
        switch self {
        case .formal: return "正式"
        case .casual: return "随意"
        case .professional: return "专业"
        case .concise: return "简洁"
        }
    }
} 