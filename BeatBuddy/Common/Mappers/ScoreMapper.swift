//
//  ScoreMapper.swift
//  BeatBuddy
//
//  Created by Muhammad Adha Fajri Jonison on 21/08/23.
//

import Foundation

final class ScoreMapper {
    static func mapScoreEntityToModel(input scoreEntity: ScoreEntity) -> ScoreModel {
        return ScoreModel(value: scoreEntity.value)
    }
    
    static func mapScoreModelToEntity(input scoreModel: ScoreModel) -> ScoreEntity {
        return ScoreEntity(value: scoreModel.value)
    }
}
