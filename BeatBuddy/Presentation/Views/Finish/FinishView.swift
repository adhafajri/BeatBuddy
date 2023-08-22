//
//  FinishView.swift
//  BeatBuddy
//
//  Created by Muhammad Adha Fajri Jonison on 15/08/23.
//

import SwiftUI

struct FinishView: View {
    @EnvironmentObject private var pathStore: PathStore
    @StateObject private var viewModel: FinishViewModel

    @StateObject private var gameLogic = GameLogic()

    init(score: ScoreModel, viewModel: FinishViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        viewModel.score = score
    }

    var body: some View {
        VStack {
            if viewModel.score.value > viewModel.highScore.value {
                Text("NEW HIGH SCORE!")
            }

            Text("SCORE: \(viewModel.score.value)")

            PrimaryButton(buttonImage: .play, text: "Play Again") {
                gameLogic.isMusicFinished = false
                gameLogic.resetGame()
                gameLogic.startGame()

                pathStore.navigateToView(routerPath: .play)
            }

            PrimaryButton(buttonImage: .menu, text: "Back To Home") {
                gameLogic.resetGame()

                pathStore.popToRoot()
            }
        }
    }
}

struct FinishView_Previews: PreviewProvider {
    static var previews: some View {
        FinishView(score: ScoreModel(value: 0), viewModel: DependencyInjection.init().provideFinishViewModel())
    }
}
