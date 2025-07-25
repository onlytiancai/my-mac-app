//
//  ContentView.swift
//  my-mac-app
//
//  Created by 胡浩 on 2025/7/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var pomodoroTimer = PomodoroTimer()
    
    var body: some View {
        VStack(spacing: 30) {
            // 标题
            Text("番茄时钟")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // 当前状态
            Text(pomodoroTimer.currentStateText)
                .font(.title2)
                .foregroundColor(stateColor)
                .fontWeight(.medium)
            
            // 圆形进度条和时间显示
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: pomodoroTimer.progress)
                    .stroke(stateColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: pomodoroTimer.progress)
                
                VStack {
                    Text(pomodoroTimer.timeString)
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundColor(stateColor)
                    
                    if pomodoroTimer.currentState == .work {
                        Text("番茄 #\(pomodoroTimer.completedPomodoros + 1)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // 控制按钮
            HStack(spacing: 20) {
                Button(action: {
                    if pomodoroTimer.isRunning {
                        pomodoroTimer.pauseTimer()
                    } else {
                        pomodoroTimer.startTimer()
                    }
                }) {
                    Image(systemName: pomodoroTimer.isRunning ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(stateColor)
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    pomodoroTimer.resetTimer()
                }) {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.gray)
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    pomodoroTimer.skipToNext()
                }) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.orange)
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // 统计信息
            VStack(spacing: 8) {
                Text("已完成番茄钟: \(pomodoroTimer.completedPomodoros)")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 20) {
                    Text("工作: 25分钟")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("短休息: 5分钟")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("长休息: 15分钟")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(40)
        .frame(minWidth: 400, minHeight: 500)
    }
    
    private var stateColor: Color {
        switch pomodoroTimer.currentState {
        case .work:
            return .red
        case .shortBreak:
            return .green
        case .longBreak:
            return .blue
        }
    }
}

#Preview {
    ContentView()
}
