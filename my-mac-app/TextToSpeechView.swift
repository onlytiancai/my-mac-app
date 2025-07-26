//
//  TextToSpeechView.swift
//  my-mac-app
//
//  Created by 胡浩 on 2025/7/26.
//

import SwiftUI
import AVFoundation
import Speech

struct TextToSpeechView: View {
    @State private var textToSpeak = ""
    @State private var isSpeaking = false
    @State private var speechRate: Float = 0.5
    @State private var speechVolume: Float = 1.0
    @State private var selectedVoice = 0
    @StateObject private var speechManager = SpeechManager()
    @StateObject private var speechRecognizer = SpeechRecognizer()
    let onBack: () -> Void
    
    private let availableVoices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix("zh") }
    
    var body: some View {
        VStack(spacing: 30) {
            // 标题
            HStack {
                Button("返回主菜单") {
                    onBack()
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
                
                Text("文本朗读")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                // 占位，保持标题居中
                Color.clear
                    .frame(width: 100)
            }
            
            // 文本输入区域
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("输入要朗读的文本:")
                        .font(.headline)
                    
                    Spacer()
                    
                    // 语音识别按钮
                    Button(action: {
                        if speechRecognizer.isRecording {
                            speechRecognizer.stopRecording()
                        } else {
                            speechRecognizer.startRecording()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: speechRecognizer.isRecording ? "mic.fill" : "mic")
                                .foregroundColor(speechRecognizer.isRecording ? .red : .blue)
                                .scaleEffect(speechRecognizer.isRecording ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), 
                                         value: speechRecognizer.isRecording)
                            
                            Text(speechRecognizer.isRecording ? "停止录音" : "语音输入")
                                .font(.caption)
                                .foregroundColor(speechRecognizer.isRecording ? .red : .blue)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(speechRecognizer.isRecording ? Color.red : Color.blue, lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(!speechRecognizer.isAuthorized)
                    
                    // 清除文本按钮
                    Button(action: {
                        textToSpeak = ""
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .padding(6)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                TextEditor(text: $textToSpeak)
                    .font(.body)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .frame(minHeight: 150)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                // 语音识别状态提示
                if speechRecognizer.isRecording {
                    HStack {
                        Image(systemName: "waveform")
                            .foregroundColor(.red)
                            .scaleEffect(1.2)
                            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), 
                                     value: speechRecognizer.isRecording)
                        
                        Text("正在录音...")
                            .font(.caption)
                            .foregroundColor(.red)
                        
                        Spacer()
                        
                        Text("说话时长: \(speechRecognizer.recordingDuration, specifier: "%.0f")s")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .transition(.opacity)
                }
                
                if !speechRecognizer.recognizedText.isEmpty && !speechRecognizer.isRecording {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        
                        Text("识别完成")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        Spacer()
                        
                        Button("添加到文本") {
                            if !textToSpeak.isEmpty {
                                textToSpeak += "\n"
                            }
                            textToSpeak += speechRecognizer.recognizedText
                            speechRecognizer.clearRecognizedText()
                        }
                        .font(.caption)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                        
                        Button("替换文本") {
                            textToSpeak = speechRecognizer.recognizedText
                            speechRecognizer.clearRecognizedText()
                        }
                        .font(.caption)
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    .padding(.horizontal, 8)
                    .transition(.opacity)
                }
                
                // 权限提示
                if !speechRecognizer.isAuthorized {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        
                        Text("需要语音识别权限才能使用语音输入功能")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Spacer()
                        
                        Button("请求权限") {
                            speechRecognizer.requestAuthorization()
                        }
                        .font(.caption)
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    .padding(8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            // 语音设置
            VStack(spacing: 15) {
                HStack {
                    Text("语音:")
                        .frame(width: 60, alignment: .leading)
                    
                    Picker("语音", selection: $selectedVoice) {
                        ForEach(0..<availableVoices.count, id: \.self) { index in
                            Text(availableVoices[index].name)
                                .tag(index)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                HStack {
                    Text("语速:")
                        .frame(width: 60, alignment: .leading)
                    
                    Slider(value: $speechRate, in: 0.1...1.0, step: 0.1)
                    
                    Text(String(format: "%.1f", speechRate))
                        .frame(width: 30)
                }
                
                HStack {
                    Text("音量:")
                        .frame(width: 60, alignment: .leading)
                    
                    Slider(value: $speechVolume, in: 0.1...1.0, step: 0.1)
                    
                    Text(String(format: "%.1f", speechVolume))
                        .frame(width: 30)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(10)
            
            // 控制按钮
            HStack(spacing: 20) {
                Button(action: {
                    if isSpeaking {
                        stopSpeaking()
                    } else {
                        startSpeaking()
                    }
                }) {
                    HStack {
                        Image(systemName: isSpeaking ? "stop.fill" : "play.fill")
                        Text(isSpeaking ? "停止" : "开始朗读")
                    }
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(isSpeaking ? Color.red : Color.blue)
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(textToSpeak.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                
                Button(action: {
                    pauseOrResumeSpeaking()
                }) {
                    HStack {
                        Image(systemName: speechManager.isPaused ? "play.fill" : "pause.fill")
                        Text(speechManager.isPaused ? "继续" : "暂停")
                    }
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(Color.orange)
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!isSpeaking)
            }
            
            Spacer()
        }
        .padding(40)
        .frame(minWidth: 550, minHeight: 700)
        .onReceive(speechManager.$isSpeaking) { newValue in
            isSpeaking = newValue
        }
        .onReceive(speechRecognizer.$recognizedText) { newText in
            // 实时更新识别的文本到输入框
            if speechRecognizer.isRecording && !newText.isEmpty {
                textToSpeak = newText
            }
        }
    }
    
    private func startSpeaking() {
        let utterance = AVSpeechUtterance(string: textToSpeak)
        
        if selectedVoice < availableVoices.count {
            utterance.voice = availableVoices[selectedVoice]
        }
        
        utterance.rate = speechRate
        utterance.volume = speechVolume
        
        speechManager.speak(utterance)
    }
    
    private func stopSpeaking() {
        speechManager.stopSpeaking()
    }
    
    private func pauseOrResumeSpeaking() {
        speechManager.pauseOrResumeSpeaking()
    }
}

// 语音合成管理器
class SpeechManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var isSpeaking = false
    private let synthesizer = AVSpeechSynthesizer()
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func speak(_ utterance: AVSpeechUtterance) {
        synthesizer.speak(utterance)
        isSpeaking = true
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }
    
    func pauseOrResumeSpeaking() {
        if synthesizer.isPaused {
            synthesizer.continueSpeaking()
        } else {
            synthesizer.pauseSpeaking(at: .immediate)
        }
    }
    
    var isPaused: Bool {
        return synthesizer.isPaused
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
    }
}

// 语音识别管理器
class SpeechRecognizer: NSObject, ObservableObject {
    @Published var recognizedText = ""
    @Published var isRecording = false
    @Published var isAuthorized = false
    @Published var recordingDuration: Double = 0
    
    private var audioEngine = AVAudioEngine()
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recordingTimer: Timer?
    
    override init() {
        super.init()
        setupSpeechRecognizer()
        checkAuthorization()
    }
    
    private func setupSpeechRecognizer() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
        speechRecognizer?.delegate = self
    }
    
    private func checkAuthorization() {
        let speechStatus = SFSpeechRecognizer.authorizationStatus()
        DispatchQueue.main.async {
            switch speechStatus {
            case .authorized:
                self.isAuthorized = true
            case .denied, .restricted, .notDetermined:
                self.isAuthorized = false
            @unknown default:
                self.isAuthorized = false
            }
        }
    }
    
    func requestAuthorization() {
        // 首先检查语音识别是否可用
        guard let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN")) else {
            print("不支持中文语音识别")
            DispatchQueue.main.async {
                self.isAuthorized = false
            }
            return
        }
        
        guard speechRecognizer.isAvailable else {
            print("语音识别服务当前不可用")
            DispatchQueue.main.async {
                self.isAuthorized = false
            }
            return
        }
        
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self?.isAuthorized = true
                    print("语音识别权限已授权")
                case .denied:
                    self?.isAuthorized = false
                    print("语音识别权限被拒绝 - 请到系统偏好设置中手动开启")
                case .restricted:
                    self?.isAuthorized = false
                    print("语音识别权限受限")
                case .notDetermined:
                    self?.isAuthorized = false
                    print("语音识别权限未确定")
                @unknown default:
                    self?.isAuthorized = false
                    print("未知的语音识别权限状态")
                }
            }
        }
    }
    
    func startRecording() {
        guard isAuthorized else {
            requestAuthorization()
            return
        }
        
        // 停止之前的任务
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        // 创建识别请求
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            print("无法创建识别请求")
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // 配置音频引擎
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("音频引擎启动失败: \(error)")
            return
        }
        
        // 开始识别
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            DispatchQueue.main.async {
                if let result = result {
                    self?.recognizedText = result.bestTranscription.formattedString
                }
                
                if error != nil || result?.isFinal == true {
                    self?.stopRecording()
                }
            }
        }
        
        isRecording = true
        recordingDuration = 0
        
        // 开始计时
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.recordingDuration += 1
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        isRecording = false
    }
    
    func clearRecognizedText() {
        recognizedText = ""
    }
}

// MARK: - SFSpeechRecognizerDelegate
extension SpeechRecognizer: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        DispatchQueue.main.async {
            // 可以在这里处理可用性变化
        }
    }
}

#Preview {
    TextToSpeechView(onBack: {})
}