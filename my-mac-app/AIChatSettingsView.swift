//
//  AIChatSettingsView.swift
//  my-mac-app
//
//  Created by AI Assistant on 2025/7/28.
//

import SwiftUI

struct AIChatSettingsView: View {
    @Binding var config: InferenceConfig
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            // 标题
            HStack {
                Text("AI 聊天设置")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("完成") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            
            // 设置内容
            VStack(spacing: 25) {
                // 模型参数设置
                GroupBox {
                    VStack(spacing: 20) {
                        // Temperature 设置
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Temperature (创造性)")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Text(String(format: "%.1f", config.temperature))
                                    .font(.monospaced(.body)())
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(6)
                            }
                            
                            Slider(value: $config.temperature, in: 0.1...2.0, step: 0.1)
                                .accentColor(.blue)
                            
                            HStack {
                                Text("保守")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("创新")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("较低的值会产生更一致、更保守的回答；较高的值会产生更有创意、更多样的回答。")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                        
                        // Max Tokens 设置
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("最大回复长度")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Text("\(config.maxTokens)")
                                    .font(.monospaced(.body)())
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(6)
                            }
                            
                            Slider(value: Binding(
                                get: { Double(config.maxTokens) },
                                set: { config.maxTokens = Int($0) }
                            ), in: 128...2048, step: 64)
                                .accentColor(.green)
                            
                            HStack {
                                Text("简短")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("详细")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("控制AI回复的最大长度。较小的值响应更快，较大的值允许更详细的回答。")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                        
                        // Top P 设置
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Top P (核心采样)")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Text(String(format: "%.1f", config.topP))
                                    .font(.monospaced(.body)())
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(6)
                            }
                            
                            Slider(value: $config.topP, in: 0.1...1.0, step: 0.1)
                                .accentColor(.orange)
                            
                            HStack {
                                Text("聚焦")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("多样")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("控制词汇选择的多样性。较低的值使AI更专注于高概率词汇。")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                        
                        // Repetition Penalty 设置
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("重复惩罚")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Text(String(format: "%.1f", config.repetitionPenalty))
                                    .font(.monospaced(.body)())
                                    .foregroundColor(.purple)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.purple.opacity(0.1))
                                    .cornerRadius(6)
                            }
                            
                            Slider(value: $config.repetitionPenalty, in: 1.0...2.0, step: 0.1)
                                .accentColor(.purple)
                            
                            HStack {
                                Text("允许重复")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("避免重复")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("控制AI避免重复内容的程度。较高的值会减少重复。")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } label: {
                    Label("模型参数", systemImage: "slider.horizontal.3")
                        .font(.headline)
                }
                
                // 预设配置
                GroupBox {
                    VStack(spacing: 16) {
                        Text("快速配置预设")
                            .font(.headline)
                        
                        HStack(spacing: 16) {
                            // 保守模式
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    config.temperature = 0.3
                                    config.maxTokens = 512
                                    config.topP = 0.7
                                    config.repetitionPenalty = 1.2
                                }
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "shield.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                    
                                    Text("保守模式")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    
                                    Text("一致、可预测")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // 平衡模式
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    config.temperature = 0.7
                                    config.maxTokens = 1024
                                    config.topP = 0.9
                                    config.repetitionPenalty = 1.1
                                }
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "scale.3d")
                                        .font(.title2)
                                        .foregroundColor(.green)
                                    
                                    Text("平衡模式")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    
                                    Text("推荐设置")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // 创意模式
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    config.temperature = 1.2
                                    config.maxTokens = 1536
                                    config.topP = 0.95
                                    config.repetitionPenalty = 1.0
                                }
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "paintbrush.fill")
                                        .font(.title2)
                                        .foregroundColor(.orange)
                                    
                                    Text("创意模式")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    
                                    Text("多样、创新")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                } label: {
                    Label("预设配置", systemImage: "star.fill")
                        .font(.headline)
                }
                
                // 性能提示
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                            
                            Text("性能提示")
                                .font(.headline)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "speedometer")
                                    .foregroundColor(.blue)
                                Text("降低最大回复长度可以提高响应速度")
                                    .font(.caption)
                            }
                            
                            HStack {
                                Image(systemName: "memorychip")
                                    .foregroundColor(.green)
                                Text("较低的 Temperature 值能减少内存使用")
                                    .font(.caption)
                            }
                            
                            HStack {
                                Image(systemName: "battery.100")
                                    .foregroundColor(.orange)
                                Text("保守模式预设最节省电池和性能")
                                    .font(.caption)
                            }
                        }
                    }
                } label: {
                    Label("优化建议", systemImage: "info.circle")
                        .font(.headline)
                }
            }
            
            Spacer()
        }
        .padding(30)
        .frame(width: 600, height: 700)
    }
}

#Preview {
    AIChatSettingsView(config: .constant(InferenceConfig()))
}