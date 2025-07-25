import Foundation
import SwiftUI

enum PomodoroState {
    case work
    case shortBreak
    case longBreak
}

class PomodoroTimer: ObservableObject {
    @Published var timeRemaining: TimeInterval = 25 * 60 // 25分钟
    @Published var isRunning = false
    @Published var currentState: PomodoroState = .work
    @Published var completedPomodoros = 0
    
    private var timer: Timer?
    private let workDuration: TimeInterval = 25 * 60 // 25分钟
    private let shortBreakDuration: TimeInterval = 5 * 60 // 5分钟
    private let longBreakDuration: TimeInterval = 15 * 60 // 15分钟
    
    var timeString: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var currentStateText: String {
        switch currentState {
        case .work:
            return "工作时间"
        case .shortBreak:
            return "短休息"
        case .longBreak:
            return "长休息"
        }
    }
    
    var progress: Double {
        let totalTime: TimeInterval
        switch currentState {
        case .work:
            totalTime = workDuration
        case .shortBreak:
            totalTime = shortBreakDuration
        case .longBreak:
            totalTime = longBreakDuration
        }
        return 1.0 - (timeRemaining / totalTime)
    }
    
    func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timerCompleted()
            }
        }
    }
    
    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer() {
        pauseTimer()
        setTimerForCurrentState()
    }
    
    private func timerCompleted() {
        pauseTimer()
        
        switch currentState {
        case .work:
            completedPomodoros += 1
            // 每完成4个番茄钟进入长休息，否则短休息
            if completedPomodoros % 4 == 0 {
                currentState = .longBreak
            } else {
                currentState = .shortBreak
            }
        case .shortBreak, .longBreak:
            currentState = .work
        }
        
        setTimerForCurrentState()
        playNotificationSound()
    }
    
    private func setTimerForCurrentState() {
        switch currentState {
        case .work:
            timeRemaining = workDuration
        case .shortBreak:
            timeRemaining = shortBreakDuration
        case .longBreak:
            timeRemaining = longBreakDuration
        }
    }
    
    private func playNotificationSound() {
        // 播放系统提示音
        NSSound.beep()
    }
    
    func skipToNext() {
        pauseTimer()
        timerCompleted()
    }
}