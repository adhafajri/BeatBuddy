//
//  GameUseCase.swift
//  BeatBuddy
//
//  Created by Muhammad Adha Fajri Jonison on 21/08/23.
//

import Foundation
import AVFAudio

protocol GameUseCaseProtocol {
    func startGame(audioPlayer: AVAudioPlayer, onAudioPeak: (_ circlePoint: CGPoint) -> Void)
    func stopGame(onStopGame: () -> Void)
}

class GameUseCase: GameUseCaseProtocol {
    var gameService: GameServiceProtocol

    init(gameService: GameServiceProtocol) {
        self.gameService = gameService
    }

    func startGame(audioPlayer: AVAudioPlayer, onAudioPeak: (_ circlePoint: CGPoint) -> Void) {
        gameService.startGame(audioPlayer: audioPlayer) { circlePoint in
            onAudioPeak(circlePoint)
        }
    }

    func stopGame(onStopGame: () -> Void) {
        gameService.stopGame { onStopGame() }
    }
}
