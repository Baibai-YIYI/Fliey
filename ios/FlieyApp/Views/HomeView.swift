//
//  HomeView.swift
//  Fliey
//
//  Created by Cursor
//
//  功能说明：首页标签 - 显示欢迎信息、历史记录和快捷操作按钮
//

import SwiftUI
import SharedCore

/**
 * 首页视图布局：
 * - 欢迎标题
 * - 最近三条 historyItems 列表（ForEach，占位）
 * - 三个快捷按钮（摘要 / 翻译 / 改写）
 */
struct HomeView: View {
    @EnvironmentObject var viewModel: MainViewModel
    
    var body: some View {
        VStack {
            // 欢迎标题
            Text("欢迎使用 Fliey")
                .font(.largeTitle)
                .padding()
            
            // 最近三条 historyItems 列表
            VStack(alignment: .leading) {
                Text("最近处理")
                    .font(.headline)
                    .padding(.horizontal)
                
                // ForEach 占位
                if viewModel.historyItems.isEmpty {
                    Text("暂无历史记录")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(Array(viewModel.historyItems.prefix(3))) { item in
                        Text(item.fileName)
                            .padding()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            // 三个快捷按钮
            HStack {
                Button("摘要") {
                    viewModel.selectedOperation = .summarize
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("翻译") {
                    viewModel.selectedOperation = .translate
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("改写") {
                    viewModel.selectedOperation = .rewrite
                }
                .padding()
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
}

// TODO: #Preview { HomeView().environmentObject(MainViewModel(documentParser: MockParser())) 