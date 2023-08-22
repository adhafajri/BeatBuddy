//
//  DependencyInjection.swift
//  BeatBuddy
//
//  Created by Muhammad Adha Fajri Jonison on 20/08/23.
//

import Foundation
import SwiftUI

protocol DependencyInjectionProtocol {
    func provideLocalDataSource() -> LocalDataSourceProtocol
    func provideRepository() -> ScoreRepositoryProtocol
    func provideScoreUseCase() -> ScoreUseCaseProtocol
    func provideMenuViewModel() -> MenuViewModel
    func providePlayViewModel() -> PlayViewModel
    func providePauseViewModel() -> PauseViewModel
    func provideFinishViewModel() -> FinishViewModel
}

final class DependencyInjection: DependencyInjectionProtocol {
    internal func provideLocalDataSource() -> LocalDataSourceProtocol {
        return LocalDataSource()
    }

    internal func provideRepository() -> ScoreRepositoryProtocol {
        let localDataSource = provideLocalDataSource()
        return ScoreRepository(localDataSource: localDataSource)
    }

    internal func provideScoreUseCase() -> ScoreUseCaseProtocol {
        let repository = provideRepository()
        return ScoreUseCase(repository: repository)
    }

    func provideMenuViewModel() -> MenuViewModel {
        let useCase = provideScoreUseCase()
        return MenuViewModel(scoreUseCase: useCase)
    }

    func providePlayViewModel() -> PlayViewModel {
        let useCase = provideScoreUseCase()
        return PlayViewModel(scoreUseCase: useCase)
    }

    func providePauseViewModel() -> PauseViewModel {
        let useCase = provideScoreUseCase()
        return PauseViewModel()
    }

    func provideFinishViewModel() -> FinishViewModel {
        let useCase = provideScoreUseCase()
        return FinishViewModel(scoreUseCase: useCase)
    }
}
