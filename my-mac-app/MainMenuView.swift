//
//  MainMenuView.swift
//  my-mac-app
//
//  Created by 胡浩 on 2025/7/26.
//

import SwiftUI

struct MainMenuView: View {
    @State private var selectedView: ViewType? = nil
    
    enum ViewType {
        case pomodoroTimer
        case textToSpeech
    }
    
    var body: some View {
        Group {
            if let selectedView = selectedView {
                switch selectedView {
                case .pomodoroTimer:
                    PomodoroTimerView(onBack: {
                        self.selectedView = nil
                    })
                case .textToSpeech:
                    TextToSpeechView(onBack: {
                        self.selectedView = nil
                    })
                }
            } else {
                mainMenu
            }
        }
    }
    
    private var mainMenu: some View {
        VStack(spacing: 40) {
            // 应用标题
            VStack(spacing: 10) {
                Image(systemName: "clock.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("我的Mac应用")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("选择一个功能开始使用")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            // 功能按钮
            VStack(spacing: 30) {
                Button(action: {
                    selectedView = .pomodoroTimer
                }) {
                    HStack(spacing: 20) {
                        Image(systemName: "timer")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("番茄时钟")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("专注工作，高效学习")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .padding(30)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    selectedView = .textToSpeech
                }) {
                    HStack(spacing: 20) {
                        Image(systemName: "speaker.wave.3")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("文本朗读")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("输入文本，语音朗读")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .padding(30)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(maxWidth: 500)
            
            Spacer()
        }
        .padding(50)
        .frame(minWidth: 600, minHeight: 500)
    }
}

#Preview {
    MainMenuView()
}