//
//  ScoreUseCase.swift
//  BeatBuddy
//
//  Created by Muhammad Adha Fajri Jonison on 20/08/23.
//

import Foundation

protocol ScoreUseCaseProtocol {
    func getHighScore() -> ScoreModel
    func updateHighScore(with newScore: ScoreModel)
}

class ScoreUseCase: ScoreUseCaseProtocol {
    private let scoreRepository: ScoreRepositoryProtocol

    init(repository: ScoreRepositoryProtocol) {
        self.scoreRepository = repository
    }

    // Fetches the current high score
    func getHighScore() -> ScoreModel {
        return scoreRepository.getHighScore()
    }

    // Updates the high score if the new score surpasses the current high score.
    // Returns true if a new high score was set, and false otherwise.
    func updateHighScore(with newScore: ScoreModel) {
        let currentHighScore = scoreRepository.getHighScore()
        if newScore.value > currentHighScore.value {
            scoreRepository.setHighScore(newScore)
        }
    }
}
