//
//  MenuViewModel.swift
//  BeatBuddy
//
//  Created by Muhammad Adha Fajri Jonison on 20/08/23.
//

import Foundation

class MenuViewModel: ObservableObject {
    private let scoreUseCase: ScoreUseCaseProtocol

    @Published var highScore: Int = 0

    init(scoreUseCase: ScoreUseCaseProtocol) {
        self.scoreUseCase = scoreUseCase
        getHighScore()
    }

    func getHighScore() {
        let score = scoreUseCase.getHighScore()
        highScore = score.value
    }
}
