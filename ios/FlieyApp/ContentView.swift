//
//  ContentView.swift
//  Fliey
//
//  Created by Cursor
//
//  功能说明：主应用的主界面视图，展示和管理文档和处理结果
// 

/*
 界面结构规划 & 交互设计：
 
 1. 主界面布局（TabView 结构）：
    - 首页标签：展示历史记录和快捷操作
    - 导入标签：支持从文件导入 PDF/DOCX/TXT
    - 设置标签：App 配置（语言首选项、AI 模式等）
 
 2. 首页标签结构：
    - 顶部：欢迎信息 + 最近操作统计
    - 中部：历史记录列表（最近处理的文档），显示文件名、操作类型和时间
    - 底部：快捷操作按钮组（"摘要"、"翻译"、"改写"）
    
    历史记录功能扩展点：
    - 本地历史记录：默认模式，保存在设备本地
    - iCloud 同步：可选模式，启用后可在用户所有设备间同步历史记录
    - 自定义云存储：预留接口，后期可接入自定义的云存储解决方案
    - 隐私保护：可设置是否上传敏感内容，或仅上传元数据
 
 3. 导入标签结构：
    - 文件选择器：支持浏览和选择本地文件
    - 文件类型筛选：PDF、DOCX、TXT
    - 上传进度指示器：显示大文件解析进度
    - 操作选择：选择要执行的 AI 操作（摘要/翻译/改写）
    - 参数配置：根据操作类型显示不同参数（如翻译目标语言）
 
 4. 设置标签结构：
    - 应用外观（Appearance）:
      - 主题: 自动（默认）/ 浅色 / 深色
      - 强调色: 蓝色（默认）/ 绿色 / 紫色 / 等
      - 文本大小: 标准（默认）/ 大 / 超大
      
    - 默认语言设置（Languages）:
      - 翻译默认目标语言: 英语（默认）/ 日语 / 法语 / 德语 / 其他
      - 界面语言: 跟随系统（默认）/ 中文 / 英文
      
    - 摘要设置（Summary）:
      - 默认摘要长度: 3句（默认）/ 5句 / 1句 / 自定义
      - 摘要风格: 简洁（默认）/ 详细 / 要点
      
    - 存储管理（Storage）:
      - 历史记录保留期: 7天（默认）/ 30天 / 永久
      - 缓存清理: 按钮操作
      - 已使用空间: 显示当前缓存大小
      
    - 同步与备份（Sync & Backup）:
      - iCloud 同步: 开启/关闭（默认关闭）
      - 数据导出: 按钮操作
      - 最近同步时间: 日期时间显示
      
    - 关于（About）:
      - 应用版本: 显示当前版本号
      - 开发者信息: 联系方式
      - 隐私政策: 链接
 
 5. 文档处理流程：
    a. 用户从首页或导入标签选择/上传文档
    b. 选择 AI 操作类型（摘要/翻译/改写）
    c. 配置相关参数（如有）
    d. 处理中显示加载状态
    e. 显示处理结果，提供复制、分享、修改选项
 
 6. 状态管理：
    - 使用 MainViewModel 管理 UI 状态
    - 文档列表状态：加载中/已加载/错误
    - 处理状态：空闲/处理中/完成/错误
    - 结果缓存：避免重复处理相同文档
 
 主要交互点：
 - 文档点击：打开详情视图
 - 处理结果长按：显示复制/分享菜单
 - 下拉刷新：更新历史记录
 - 向左滑动记录：显示删除选项
 */ 

import SwiftUI
import SharedCore

struct ContentView: View {
    // TODO: 绑定 MainViewModel 为 @StateObject
    @StateObject private var viewModel = MainViewModel(documentParser: MockParser())
    
    var body: some View {
        // TODO: 使用 TabView { HomeView(); ImportView(); SettingsView() }
        TabView {
            HomeView()
                .tabItem {
                    Label("首页", systemImage: "house")
                }
            
            ImportView()
                .tabItem {
                    Label("导入", systemImage: "square.and.arrow.down")
                }
            
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
        }
        .environmentObject(viewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 