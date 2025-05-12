//
//  ImportView.swift
//  Fliey
//
//  Created by Cursor
//
//  功能说明：导入标签 - 允许用户选择文件并设置处理选项
//

import SwiftUI
import SharedCore

/**
 * 导入视图布局：
 * - "选择文件按钮" → 调用 DocumentPicker（后续实现）
 * - 操作选择器（Segment）绑定 selectedOperation
 * - 运行按钮 → 调用 MainViewModel.importFile()
 */
struct ImportView: View {
    @EnvironmentObject var viewModel: MainViewModel
    @State private var showingDocumentPicker = false
    @State private var selectedFileName: String?
    
    var body: some View {
        VStack(spacing: 20) {
            // 标题
            Text("导入文件")
                .font(.largeTitle)
                .padding()
            
            // 选择文件按钮
            Button(action: {
                showingDocumentPicker = true
            }) {
                HStack {
                    Image(systemName: "doc")
                    Text(selectedFileName ?? "选择文件")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            }
            
            // 操作选择器
            Picker("操作类型", selection: $viewModel.selectedOperation) {
                Text("摘要").tag(Operation.summarize)
                Text("翻译").tag(Operation.translate)
                Text("改写").tag(Operation.rewrite)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // 当前选中的操作对应的配置选项
            if viewModel.selectedOperation == .translate {
                TextField("目标语言", text: $viewModel.targetLanguage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
            } else if viewModel.selectedOperation == .summarize {
                Stepper("摘要长度: \(viewModel.summaryLimit) 句", value: $viewModel.summaryLimit, in: 1...10)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            // 运行按钮
            Button(action: {
                // 调用 MainViewModel.importFile()
                // 在实际实现中需要传入文件 URL
            }) {
                Text("开始处理")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedFileName == nil ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(selectedFileName == nil)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding()
        // DocumentPicker 在这里实现（后续添加）
    }
}

// TODO: #Preview { ImportView().environmentObject(MainViewModel(documentParser: MockParser())) 