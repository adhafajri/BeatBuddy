//
//  RouterPath.swift
//  BeatBuddy
//
//  Created by Muhammad Adha Fajri Jonison on 21/08/23.
//

import Foundation
import SwiftUI

enum RouterPath: Hashable {
    case menu
    case play
    case pause
    case finish(ScoreModel)

    @ViewBuilder
    var view: some View {
        switch self {
        case .menu:
            MenuView(viewModel: DependencyInjection.init().provideMenuViewModel())
        case .play:
            PlayView(viewModel: DependencyInjection.init().providePlayViewModel())
        case .pause:
            PauseView()
        case .finish(let score):
            FinishView(score: score, viewModel: DependencyInjection.init().provideFinishViewModel())
        }
    }
}
