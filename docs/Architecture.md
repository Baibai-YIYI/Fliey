# Fliey 架构设计草图

## 功能流程图

Share Sheet → FlieyShare Extension
↘︎ (调用 WritingTools Service)
Main App ← SharedCore (DocumentParser + AIService)

markdown
复制
编辑

## 模块拆分

| 层级         | 说明 |
|--------------|------|
| **SharedCore** | 纯 Swift，可在 Windows 编译；负责解析 PDF/DOCX、调用 WritingTools；所有业务逻辑集中于此 |
| **FlieyApp**  | SwiftUI 主程序；文档导入、结果展示、Widget/Shortcut 调度 |
| **FlieyShare**| 系统 Share Extension，选中文本或文件后唤起；UI 极简，只负责把请求传给 SharedCore |

## 数据流描述

> 文本 / 文件路径 → `DocumentParser` → plain text → `AIService` → summary / translation → 回传 UI 