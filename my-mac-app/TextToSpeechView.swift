//
//  TextToSpeechView.swift
//  my-mac-app
//
//  Created by 胡浩 on 2025/7/26.
//

import SwiftUI
import AVFoundation

struct TextToSpeechView: View {
    @State private var textToSpeak = ""
    @State private var isSpeaking = false
    @State private var speechRate: Float = 0.5
    @State private var speechVolume: Float = 1.0
    @State private var selectedVoice = 0
    @StateObject private var speechManager = SpeechManager()
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
                Text("输入要朗读的文本:")
                    .font(.headline)
                
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
        .frame(minWidth: 500, minHeight: 600)
        .onReceive(speechManager.$isSpeaking) { newValue in
            isSpeaking = newValue
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

#Preview {
    TextToSpeechView(onBack: {})
}