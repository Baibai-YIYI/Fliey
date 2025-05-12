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

## 组件间通信

Fliey 采用 App Group 机制实现 Extension 与主应用之间的数据共享：

1. Share Extension 在完成 AI 处理后，将结果写入 App Group（UserDefaults）
2. 主应用启动或从后台返回时检查 App Group，读取并渲染处理结果
3. `SharedResultBridge` 工具类封装了这一通信机制，简化跨组件调用

### 数据流示意图

```mermaid
graph LR
    A[Share Extension] -->|处理文件/文本| B[DocumentParser]
    B -->|提取纯文本| C[AIService]
    C -->|处理结果| D[App Group]
    D -->|读取结果| E[Main App]
    E -->|显示结果| F[用户界面]
```

### 详细流程

```mermaid
sequenceDiagram
    participant User as 用户
    participant Share as 系统分享菜单
    participant Ext as FlieyShare扩展
    participant Parser as DocumentParser
    participant AI as AIService
    participant Group as App Group
    participant App as 主应用
    
    User->>Share: 选择文本/文件
    Share->>Ext: 唤起分享扩展
    Ext->>Parser: 解析文件(如果是文件)
    Parser-->>Ext: 返回纯文本
    Ext->>AI: 请求AI处理
    AI-->>Ext: 返回处理结果
    Ext->>Group: 保存结果
    Ext-->>User: 显示完成提示
    
    User->>App: 打开主应用
    App->>Group: 检查是否有新结果
    Group-->>App: 返回处理结果
    App->>App: 渲染结果UI
    App-->>User: 展示结果
```

## 技术栈

- **Swift** + **SwiftUI**: 主要开发语言和UI框架
- **Apple Intelligence API**: iOS 18+ 提供的 WritingTools 服务
- **PDFKit**: 解析PDF文档
- **App Group**: 跨Extension通信
- **Shared UserDefaults**: 共享设置和结果 

> Day 7 已完成：SwiftUI 原型三分屏 + 假数据流通 