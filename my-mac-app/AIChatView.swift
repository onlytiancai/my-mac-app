//
//  AIChatView.swift
//  my-mac-app
//
//  Created by AI Assistant on 2025/7/28.
//

import SwiftUI

struct AIChatView: View {
    @StateObject private var aiManager = LocalAIInferenceManager()
    @State private var messageText = ""
    @State private var showSettings = false
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部工具栏
            topToolbar
            
            // 主要内容区域
            if !aiManager.isModelLoaded {
                modelSetupView
            } else {
                chatView
            }
        }
        .frame(minWidth: 700, minHeight: 600)
        .sheet(isPresented: $showSettings) {
            AIChatSettingsView(config: $aiManager.config)
        }
    }
    
    // 顶部工具栏
    private var topToolbar: some View {
        HStack {
            Button("返回主菜单") {
                onBack()
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("AI 聊天助手")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("基于 Google Gemma 3B 模型 • 本地推理")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                // 设置按钮
                Button(action: { showSettings = true }) {
                    Image(systemName: "gear")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
                
                // 清除对话按钮
                Button(action: { aiManager.clearChat() }) {
                    Image(systemName: "trash")
                        .font(.title2)
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(aiManager.messages.isEmpty)
                
                // 状态指示器
                HStack(spacing: 6) {
                    Circle()
                        .fill(aiManager.isModelLoaded ? .green : .gray)
                        .frame(width: 8, height: 8)
                    
                    Text(aiManager.isModelLoaded ? "在线" : "离线")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
    }
    
    // 模型设置界面
    private var modelSetupView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // 图标和标题
            VStack(spacing: 20) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                VStack(spacing: 8) {
                    Text("Google Gemma 3B 模型")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("本地AI推理 • 隐私保护")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
            
            // 状态信息
            VStack(spacing: 16) {
                // 加载进度
                if aiManager.isLoading {
                    VStack(spacing: 12) {
                        ProgressView(value: aiManager.loadingProgress)
                            .progressViewStyle(LinearProgressViewStyle())
                            .frame(width: 300)
                        
                        Text(aiManager.loadingStatus)
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                }
                
                // 错误信息
                if let errorMessage = aiManager.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // 状态文本
                if !aiManager.isLoading && aiManager.errorMessage == nil {
                    Text(aiManager.loadingStatus)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            
            // 操作按钮
            VStack(spacing: 16) {
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let modelPath = documentsPath.appendingPathComponent("gemma-3b-model.mlpackage").path
                
                if !FileManager.default.fileExists(atPath: modelPath) {
                    Button(action: {
                        Task {
                            await aiManager.downloadModel()
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.down.circle.fill")
                            Text("下载 Gemma 3B 模型")
                        }
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(aiManager.isLoading)
                    
                    Text("模型大小约 5GB，首次下载需要一些时间")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Button(action: {
                        Task {
                            await aiManager.loadModel()
                        }
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("加载模型")
                        }
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(aiManager.isLoading)
                }
            }
            
            Spacer()
            
            // 特性说明
            VStack(spacing: 12) {
                Text("功能特点")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 40) {
                    VStack(spacing: 8) {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(.green)
                        Text("隐私保护")
                            .font(.caption)
                        Text("本地处理")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 8) {
                        Image(systemName: "wifi.slash")
                            .foregroundColor(.blue)
                        Text("离线可用")
                            .font(.caption)
                        Text("无需网络")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 8) {
                        Image(systemName: "speedometer")
                            .foregroundColor(.orange)
                        Text("快速响应")
                            .font(.caption)
                        Text("本地推理")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .foregroundColor(.primary)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
        .padding(40)
    }
    
    // 聊天界面
    private var chatView: some View {
        VStack(spacing: 0) {
            // 消息列表
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(aiManager.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                        
                        // 输入中指示器
                        if aiManager.isGenerating {
                            HStack {
                                TypingIndicator()
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
                .onChange(of: aiManager.messages.count) {
                    if let lastMessage = aiManager.messages.last {
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            // 输入区域
            messageInputArea
        }
    }
    
    // 消息输入区域
    private var messageInputArea: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // 文本输入框
                TextField("输入您的消息...", text: $messageText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...5)
                    .onSubmit {
                        sendMessage()
                    }
                
                // 发送按钮
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || aiManager.isGenerating)
            }
            
            // 状态信息
            HStack {
                if aiManager.isGenerating {
                    HStack(spacing: 6) {
                        ProgressView()
                            .scaleEffect(0.7)
                        Text("AI正在思考...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Text("本地AI助手 • 完全离线")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
    }
    
    // 发送消息
    private func sendMessage() {
        let message = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty && !aiManager.isGenerating else { return }
        
        messageText = ""
        
        Task {
            await aiManager.sendMessage(message)
        }
    }
}

// 消息气泡组件
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.isUser {
                Spacer(minLength: 50)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(BubbleShape(isFromCurrentUser: true))
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Circle()
                    .fill(Color.blue)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.caption)
                    )
            } else {
                Circle()
                    .fill(Color.green)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.white)
                            .font(.caption)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(BubbleShape(isFromCurrentUser: false))
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer(minLength: 50)
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// 自定义气泡形状
struct BubbleShape: Shape {
    let isFromCurrentUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 16
        let path = Path { p in
            if isFromCurrentUser {
                // 用户消息气泡 - 右侧尖角
                p.move(to: CGPoint(x: radius, y: 0))
                p.addLine(to: CGPoint(x: rect.width - radius, y: 0))
                p.addQuadCurve(to: CGPoint(x: rect.width, y: radius), control: CGPoint(x: rect.width, y: 0))
                p.addLine(to: CGPoint(x: rect.width, y: rect.height - radius))
                p.addQuadCurve(to: CGPoint(x: rect.width - radius, y: rect.height), control: CGPoint(x: rect.width, y: rect.height))
                p.addLine(to: CGPoint(x: radius, y: rect.height))
                p.addQuadCurve(to: CGPoint(x: 0, y: rect.height - radius), control: CGPoint(x: 0, y: rect.height))
                p.addLine(to: CGPoint(x: 0, y: radius))
                p.addQuadCurve(to: CGPoint(x: radius, y: 0), control: CGPoint(x: 0, y: 0))
            } else {
                // AI消息气泡 - 左侧尖角
                p.move(to: CGPoint(x: radius, y: 0))
                p.addLine(to: CGPoint(x: rect.width - radius, y: 0))
                p.addQuadCurve(to: CGPoint(x: rect.width, y: radius), control: CGPoint(x: rect.width, y: 0))
                p.addLine(to: CGPoint(x: rect.width, y: rect.height - radius))
                p.addQuadCurve(to: CGPoint(x: rect.width - radius, y: rect.height), control: CGPoint(x: rect.width, y: rect.height))
                p.addLine(to: CGPoint(x: radius, y: rect.height))
                p.addQuadCurve(to: CGPoint(x: 0, y: rect.height - radius), control: CGPoint(x: 0, y: rect.height))
                p.addLine(to: CGPoint(x: 0, y: radius))
                p.addQuadCurve(to: CGPoint(x: radius, y: 0), control: CGPoint(x: 0, y: 0))
            }
        }
        return path
    }
}

// 输入中指示器
struct TypingIndicator: View {
    @State private var animationPhase = 0
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color.green)
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.white)
                        .font(.caption)
                )
            
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.gray.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .scaleEffect(animationPhase == index ? 1.3 : 0.8)
                        .animation(.easeInOut(duration: 0.6).repeatForever().delay(Double(index) * 0.2), value: animationPhase)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.1))
            .clipShape(BubbleShape(isFromCurrentUser: false))
        }
        .onAppear {
            withAnimation {
                animationPhase = 2
            }
        }
    }
}

#Preview {
    AIChatView(onBack: {})
}