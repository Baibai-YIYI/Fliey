//
//  SettingsView.swift
//  Fliey
//
//  Created by Cursor
//
//  功能说明：设置标签 - 管理应用参数和用户偏好设置
//

import SwiftUI
import SharedCore

/**
 * 设置视图布局：
 * - 主题切换开关
 * - 默认目标语言 TextField 绑定 targetLanguage
 * - 摘要长度 Stepper 绑定 summaryLimit
 * - "读取共享结果" Toggle（绑定布尔值，默认为开）
 */
struct SettingsView: View {
    @EnvironmentObject var viewModel: MainViewModel
    @State private var isDarkMode = false
    @State private var readSharedResults = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("外观")) {
                    Toggle("深色模式", isOn: $isDarkMode)
                }
                
                Section(header: Text("翻译设置")) {
                    TextField("默认目标语言", text: $viewModel.targetLanguage)
                }
                
                Section(header: Text("摘要设置")) {
                    Stepper("摘要长度: \(viewModel.summaryLimit) 句", 
                           value: $viewModel.summaryLimit, 
                           in: 1...10)
                }
                
                Section(header: Text("共享设置")) {
                    Toggle("读取共享结果", isOn: $readSharedResults)
                }
            }
            .navigationTitle("设置")
        }
    }
}

// TODO: #Preview { SettingsView().environmentObject(MainViewModel(documentParser: MockParser())) 