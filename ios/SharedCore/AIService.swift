/// Fliey 所有离线 AI 调用统一入口
/// - Supported ops: summary / translate / rewrite
protocol AIServiceProtocol {
    /// 对传入文本执行离线 Apple Intelligence 请求
    /// - Parameters:
    ///   - text: 纯文本
    ///   - op:   Operation.summary / .translate / .rewrite
    ///   - targetLang: 目标语言（translate 时必填）
    /// - Returns: Result<String, Error>
    func process(_ text: String,
                 op: Operation,
                 targetLang: String?) async -> Result<String, Error>
}

/// iOS 18+ 使用 WritingTools API 的默认实现
final class AIService: AIServiceProtocol { /* TODO: Day 4 编码 */ }

enum Operation { case summary, translate, rewrite }
