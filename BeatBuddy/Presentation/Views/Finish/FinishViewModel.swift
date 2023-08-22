//
//  FinishViewModel.swift
//  BeatBuddy
//
//  Created by Muhammad Adha Fajri Jonison on 20/08/23.
//

import Foundation

class FinishViewModel: ObservableObject {
    private let scoreUseCase: ScoreUseCaseProtocol

    @Published var score: ScoreModel = ScoreModel(value: 0)
    @Published var highScore: ScoreModel = ScoreModel(value: 0)

    init(scoreUseCase: ScoreUseCaseProtocol) {
        self.scoreUseCase = scoreUseCase

        fetchHighScore()
        updateHighScore()
    }

    func updateHighScore() {
        scoreUseCase.updateHighScore(with: score)
    }

    func fetchHighScore() {
        highScore = scoreUseCase.getHighScore()
    }
}
