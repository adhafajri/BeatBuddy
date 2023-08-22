//
//  GameService.swift
//  BeatBuddy
//
//  Created by Muhammad Adha Fajri Jonison on 21/08/23.
//

import Foundation
import AVFAudio
import UIKit

protocol GameServiceProtocol {
    func startGame(audioPlayer: AVAudioPlayer, onAudioPeak: (_ circlePoint: CGPoint) -> Void)
    func createCirclePoint() -> CGPoint
    func stopGame(onStopGame: () -> Void)
}

class GameService: GameServiceProtocol {
    var gameTimer: Timer?

    var previousRandomX: CGFloat = 0.0
    var previousRandomY: CGFloat = 0.0

    func startGame(audioPlayer: AVAudioPlayer, onAudioPeak: (_ circlePoint: CGPoint) -> Void) {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            audioPlayer.updateMeters()
            let power = audioPlayer.peakPower(forChannel: 0)
            
            guard power > -5.0 else {
                return
            }
            
            let circlePoint = self.createCirclePoint()
            onAudioPeak(circlePoint)
        }
    }
    
    func createCirclePoint() -> CGPoint {
        let screenBounds = UIScreen.main.bounds
        let normalizedCircleRadius = 100 / min(screenBounds.width, screenBounds.height)
        
        var randomX: CGFloat = 0.0
        var randomY: CGFloat = 0.0
        
        repeat {
            randomX = CGFloat.random(in: normalizedCircleRadius...1-normalizedCircleRadius)
            randomY = CGFloat.random(in: normalizedCircleRadius...1-normalizedCircleRadius)
        } while abs(randomX - self.previousRandomX) < normalizedCircleRadius && abs(randomY - self.previousRandomY) < normalizedCircleRadius
        
        return CGPoint(x: randomX, y: randomY)
    }
    
    
    func stopGame(onStopGame: () -> Void) {
        gameTimer?.invalidate() // Invalidate the timer when the game stops
        gameTimer = nil // Set the timer to nil to avoid any retain cycles
        
        onStopGame()
    }
}
