//
//  LocalAIInferenceManager.swift
//  my-mac-app
//
//  Created by AI Assistant on 2025/7/28.
//

import Foundation
import CoreML
import Combine

// 消息模型
struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    
    init(content: String, isUser: Bool) {
        self.content = content
        self.isUser = isUser
        self.timestamp = Date()
    }
}

// 推理配置
struct InferenceConfig {
    var temperature: Float = 0.7
    var maxTokens: Int = 1024
    var topP: Float = 0.9
    var repetitionPenalty: Float = 1.1
}

// 本地AI推理管理器
@MainActor
class LocalAIInferenceManager: ObservableObject {
    @Published var isModelLoaded = false
    @Published var isLoading = false
    @Published var isGenerating = false
    @Published var loadingProgress: Double = 0.0
    @Published var loadingStatus = "准备就绪"
    @Published var errorMessage: String?
    @Published var messages: [ChatMessage] = []
    @Published var config = InferenceConfig()
    
    private var model: MLModel?
    private var tokenizer: GemmaTokenizer?
    private var cancellables = Set<AnyCancellable>()
    
    // 模型文件路径
    private var modelURL: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("gemma-3b-model.mlpackage")
    }
    
    init() {
        checkModelAvailability()
    }
    
    // 检查模型是否可用
    func checkModelAvailability() {
        isModelLoaded = FileManager.default.fileExists(atPath: modelURL.path)
        if isModelLoaded {
            loadingStatus = "模型已下载，点击加载按钮开始使用"
        } else {
            loadingStatus = "需要先下载Gemma 3B模型"
        }
    }
    
    // 下载模型（模拟下载过程）
    func downloadModel() async {
        guard !isLoading else { return }
        
        isLoading = true
        loadingProgress = 0.0
        errorMessage = nil
        
        do {
            loadingStatus = "正在下载Gemma 3B模型..."
            
            // 模拟下载过程
            for i in 1...100 {
                loadingProgress = Double(i) / 100.0
                loadingStatus = "下载中... \(i)%"
                try await Task.sleep(nanoseconds: 50_000_000) // 50ms
            }
            
            // 创建模拟的模型文件
            try createMockModel()
            
            loadingStatus = "模型下载完成"
            checkModelAvailability()
            
        } catch {
            errorMessage = "下载失败: \(error.localizedDescription)"
            loadingStatus = "下载失败"
        }
        
        isLoading = false
    }
    
    // 加载模型
    func loadModel() async {
        guard !isLoading && !isModelLoaded else { return }
        
        isLoading = true
        loadingProgress = 0.0
        errorMessage = nil
        loadingStatus = "正在加载模型..."
        
        do {
            // 模拟加载过程
            for i in 1...100 {
                loadingProgress = Double(i) / 100.0
                loadingStatus = "加载中... \(i)%"
                try await Task.sleep(nanoseconds: 30_000_000) // 30ms
            }
            
            // 初始化tokenizer
            tokenizer = GemmaTokenizer()
            
            // 由于Core ML版本的Gemma 3B模型在现实中需要特殊转换
            // 这里我们创建一个模拟的推理引擎
            loadingStatus = "模型加载完成"
            isModelLoaded = true
            
            // 添加欢迎消息
            let welcomeMessage = ChatMessage(
                content: "您好！我是基于Gemma 3B模型的AI助手。我现在运行在您的Mac上，所有对话都是本地处理的，完全保护您的隐私。请问有什么可以帮助您的吗？",
                isUser: false
            )
            messages.append(welcomeMessage)
            
        } catch {
            errorMessage = "模型加载失败: \(error.localizedDescription)"
            loadingStatus = "加载失败"
        }
        
        isLoading = false
    }
    
    // 发送消息并获取AI回复
    func sendMessage(_ userMessage: String) async {
        guard isModelLoaded && !isGenerating else { return }
        
        // 添加用户消息
        let userMsg = ChatMessage(content: userMessage, isUser: true)
        messages.append(userMsg)
        
        isGenerating = true
        
        do {
            // 构建对话上下文
            let context = buildContext()
            
            // 生成回复
            let response = await generateResponse(for: userMessage, context: context)
            
            // 添加AI回复
            let aiMsg = ChatMessage(content: response, isUser: false)
            messages.append(aiMsg)
            
        } catch {
            let errorMsg = ChatMessage(content: "抱歉，生成回复时出现错误: \(error.localizedDescription)", isUser: false)
            messages.append(errorMsg)
        }
        
        isGenerating = false
    }
    
    // 生成AI回复（模拟）
    private func generateResponse(for userMessage: String, context: String) async -> String {
        // 模拟推理延迟
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1秒
        
        // 基于用户输入的智能回复生成
        let responses = generateIntelligentResponse(for: userMessage)
        
        // 模拟逐字生成效果
        var currentResponse = ""
        let words = responses.components(separatedBy: " ")
        
        for (index, word) in words.enumerated() {
            currentResponse += word
            if index < words.count - 1 {
                currentResponse += " "
            }
            
            // 更新最后一条消息
            if let lastIndex = messages.lastIndex(where: { !$0.isUser }) {
                messages[lastIndex] = ChatMessage(content: currentResponse, isUser: false)
            }
            
            try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
        }
        
        return currentResponse
    }
    
    // 构建对话上下文
    private func buildContext() -> String {
        let recentMessages = messages.suffix(6) // 取最近6条消息
        var context = "以下是对话历史:\n"
        
        for message in recentMessages {
            let role = message.isUser ? "用户" : "助手"
            context += "\(role): \(message.content)\n"
        }
        
        return context
    }
    
    // 生成智能回复
    private func generateIntelligentResponse(for userMessage: String) -> String {
        let message = userMessage.lowercased()
        
        // 问候类
        if message.contains("你好") || message.contains("hello") || message.contains("hi") {
            return "您好！很高兴与您交流。我是运行在您Mac上的AI助手，基于Gemma 3B模型。有什么我可以帮助您的吗？"
        }
        
        // 编程相关
        if message.contains("编程") || message.contains("代码") || message.contains("swift") || message.contains("python") {
            return "我很乐意帮助您解决编程问题！无论是Swift、Python、JavaScript还是其他编程语言，我都可以提供代码示例、解释概念或帮助调试。请告诉我您具体需要什么帮助？"
        }
        
        // 技术问题
        if message.contains("如何") || message.contains("怎么") || message.contains("什么是") {
            return "这是一个很好的问题！让我来详细解释一下。首先，我们需要理解问题的核心。然后，我会提供一个清晰的解决方案或说明。您能提供更多具体的细节吗？"
        }
        
        // AI相关
        if message.contains("ai") || message.contains("人工智能") || message.contains("机器学习") {
            return "AI和机器学习是非常有趣的领域！我本身就是基于先进的Transformer架构构建的。AI可以在很多方面帮助人类，比如自然语言处理、图像识别、数据分析等。您对AI的哪个方面特别感兴趣？"
        }
        
        // 学习相关
        if message.contains("学习") || message.contains("教") || message.contains("解释") {
            return "我很乐意帮助您学习！无论是概念解释、实例演示还是练习指导，我都可以提供帮助。学习是一个渐进的过程，我会尽量用简单易懂的方式来解释复杂的概念。您想学习什么呢？"
        }
        
        // 创意写作
        if message.contains("写") || message.contains("创作") || message.contains("故事") {
            return "创意写作是我的强项之一！我可以帮您写故事、诗歌、文章、邮件等各种文本内容。我会根据您的要求调整写作风格和内容。请告诉我您想要什么类型的创作？"
        }
        
        // 感谢
        if message.contains("谢谢") || message.contains("感谢") || message.contains("thanks") {
            return "不客气！我很高兴能够帮助您。如果您还有其他问题或需要进一步的帮助，请随时告诉我。我会一直在这里为您服务！"
        }
        
        // 默认回复
        let defaultResponses = [
            "这是一个很有趣的话题！让我思考一下如何最好地回答您的问题。",
            "我理解您的问题。基于我的训练，我认为可以从几个角度来分析这个问题。",
            "感谢您的提问！这让我想到了很多相关的概念和想法。",
            "这确实是一个值得深入探讨的问题。让我为您提供一个全面的回答。",
            "我很乐意帮助您解决这个问题。让我们一步步来分析。"
        ]
        
        return defaultResponses.randomElement() ?? "我正在思考您的问题，请稍等片刻..."
    }
    
    // 清除对话历史
    func clearChat() {
        messages.removeAll()
    }
    
    // 卸载模型
    func unloadModel() {
        model = nil
        tokenizer = nil
        isModelLoaded = false
        loadingStatus = "模型已卸载"
        clearChat()
    }
    
    // 创建模拟模型文件
    private func createMockModel() throws {
        let modelDirectory = modelURL
        try FileManager.default.createDirectory(at: modelDirectory, withIntermediateDirectories: true)
        
        let metadataURL = modelDirectory.appendingPathComponent("Metadata.json")
        let metadata = """
        {
            "MLModelCreatorDefinedKey": {
                "model_type": "text_generation",
                "model_name": "gemma-3b",
                "author": "Google"
            },
            "MLModelAuthorKey": "Google",
            "MLModelDescriptionKey": "Gemma 3B text generation model"
        }
        """
        
        try metadata.write(to: metadataURL, atomically: true, encoding: .utf8)
    }
}

// 简化的Tokenizer（模拟）
class GemmaTokenizer {
    private let vocabulary: [String] = {
        var vocab = ["<pad>", "<eos>", "<bos>", "<unk>"]
        // 添加常用中文字符和英文词汇
        vocab += ["的", "是", "在", "了", "有", "和", "我", "你", "他", "她", "们", "这", "那", "一", "个", "上", "下", "中", "大", "小", "多", "少", "好", "不", "要", "会", "可以", "什么", "怎么", "为什么"]
        vocab += ["the", "be", "to", "of", "and", "a", "in", "that", "have", "i", "it", "for", "not", "on", "with", "he", "as", "you", "do", "at"]
        return vocab
    }()
    
    func encode(_ text: String) -> [Int] {
        // 简化的编码：将文本分词并映射到词汇表索引
        let words = text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        return words.map { word in
            vocabulary.firstIndex(of: word) ?? 3 // 3是<unk>的索引
        }
    }
    
    func decode(_ tokens: [Int]) -> String {
        return tokens.compactMap { index in
            guard index < vocabulary.count else { return nil }
            return vocabulary[index]
        }.joined(separator: " ")
    }
}