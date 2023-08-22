//
//  ScoreRepository.swift
//  BeatBuddy
//
//  Created by Muhammad Adha Fajri Jonison on 21/08/23.
//

import Foundation

protocol ScoreRepositoryProtocol {
    func setHighScore(_ score: ScoreModel)
    func getHighScore() -> ScoreModel
}

class ScoreRepository: ScoreRepositoryProtocol {
    let localDataSource: LocalDataSourceProtocol

    init(localDataSource: LocalDataSourceProtocol) {
        self.localDataSource = localDataSource
    }

    func setHighScore(_ score: ScoreModel) {
        let score = ScoreMapper.mapScoreModelToEntity(input: score)
        localDataSource.setHighScore(score)
    }

    func getHighScore() -> ScoreModel {
        let score = ScoreMapper.mapScoreEntityToModel(input: localDataSource.getHighScore())

        return score
    }
}
