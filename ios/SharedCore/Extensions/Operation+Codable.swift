//
//  Operation+Codable.swift
//  Fliey
//
//  Created by Cursor
//
//  功能说明：为Operation和AIResponse类型提供Codable实现，供多个模块共享
//

import Foundation

// MARK: - 扩展 AIResponse 以支持 Codable

extension AIResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case text, operation, duration, rawOutput, markdownFormatted
    }
}

// MARK: - 扩展 Operation 以支持 Codable

extension Operation: Codable {
    private enum OperationType: String, Codable {
        case summarize, translate, rewrite
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .summarize:
            try container.encode(OperationType.summarize.rawValue)
        case .translate:
            try container.encode(OperationType.translate.rawValue)
        case .rewrite:
            try container.encode(OperationType.rewrite.rawValue)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let type = try container.decode(String.self)
        
        switch type {
        case OperationType.summarize.rawValue:
            self = .summarize
        case OperationType.translate.rawValue:
            self = .translate
        case OperationType.rewrite.rawValue:
            self = .rewrite
        default:
            self = .summarize // 默认值
        }
    }
} 