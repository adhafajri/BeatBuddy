//
//  PlayViewModel.swift
//  BeatBuddy
//
//  Created by Muhammad Adha Fajri Jonison on 20/08/23.
//

import Foundation

class PlayViewModel: ObservableObject {
    private let gameUseCase: GameUseCaseProtocol
    private let musicUseCase: MusicUseCaseProtocol

    @Published var circles: [CircleModel] = []
    
    @Published var score: ScoreModel = ScoreModel(value: 0)
    @Published var animateScore = false

    @Published var comboScore: ScoreModel = ScoreModel(value: 0)
    @Published var animateComboScore = false
    
    @Published var isMusicFinished = false

    init(gameUseCase: GameUseCaseProtocol, musicUseCase: MusicUseCaseProtocol) {
        self.gameUseCase = gameUseCase as! GameUseCase
        self.musicUseCase = musicUseCase
    }
    
    func startGame() throws {
        try musicUseCase.playMusic(music: MusicModel(name: "song"))
        
        guard let player = musicUseCase.audioService.player else {
            return
        }
        
        gameUseCase.startGame(audioPlayer: player) { circlePoint in
            let circle = CircleModel(point: circlePoint)
            circles.append(circle)
        }
    }
    
    func stopGame() {
        gameUseCase.stopGame { circles.removeAll() }
    }

    func increaseScore() {
        self.animateScore = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.animateScore = false
        }

        score.value += 1
    }

    func increaseComboScore() {
        self.animateComboScore = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.animateComboScore = false
        }

        comboScore.value += 1
    }

    func resetComboScore() {
        comboScore.value = 0
    }
}

extension PlayViewModel: GameUseCaseDelegate {
    func showCircle(x: CGFloat, y: CGFloat) {
        <#code#>
    }
    
    func removeAllCircle() {
        <#code#>
    }
    

}
