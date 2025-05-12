//
//  ShareViewController.swift
//  Fliey
//
//  Created by Cursor
//
//  功能说明：Share Extension的视图控制器，接收系统分享内容并处理
//
//  NSExtensionActivationRule: 支持的文件类型
//  - public.plain-text (纯文本)
//  - com.adobe.pdf (PDF文档)
//  - org.openxmlformats.wordprocessingml.document (DOCX文档)
//
//  Principal Class: ShareViewController
//
//  数据共享: 使用 UserDefaults(suiteName: "group.com.<you>.Fliey") 与主 App 共享结果
//