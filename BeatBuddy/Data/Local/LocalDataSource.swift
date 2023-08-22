//
//  AppStorageHighScoreDataSource.swift
//  BeatBuddy
//
//  Created by Muhammad Adha Fajri Jonison on 20/08/23.
//

import Foundation
import SwiftUI

protocol LocalDataSourceProtocol {
    func getHighScore() -> ScoreEntity
    func setHighScore(_ score: ScoreEntity)
}

class LocalDataSource: LocalDataSourceProtocol {
    @AppStorage("highScore") private var storedHighScoreValue: Int = 0

    // Retrieve the high score
    func getHighScore() -> ScoreEntity {
        let score = ScoreEntity(value: storedHighScoreValue)
        return score
    }

    // Save a new high score if it's higher than the current one
    func setHighScore(_ score: ScoreEntity) {
        storedHighScoreValue = score.value
    }
}
