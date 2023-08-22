//
//  PlayView.swift
//  BeatBuddy
//
//  Created by Muhammad Adha Fajri Jonison on 15/08/23.
//

import SwiftUI

struct PlayView: View {
    @EnvironmentObject private var pathStore: PathStore
    @StateObject private var viewModel: PlayViewModel

    init(viewModel: PlayViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            CameraView(
                countdownCircleView: gameLogic.countdownCircleView,
                gameLogic: gameLogic
            )
            .ignoresSafeArea()

            VStack {
                Spacer().fixedSize().padding(4)

                HStack {
                    Spacer().fixedSize()

                    Text("SCORE: \(viewModel.score.value)")
                        .font(.largeTitle)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .scaleEffect(self.viewModel.animateScore ? 1.5 : 1.0)
                        .foregroundColor(self.viewModel.animateScore ? .red : .black)
                        .padding(.top)

                    Spacer()

                    PrimaryButton(buttonImage: .pause, text: "Pause") {
                        pathStore.navigateToView(routerPath: .pause)
                        viewModel.stopGame()
                    }

                    Spacer().fixedSize()
                }

                Spacer()

                if viewModel.comboScore.value > 1 {
                    Text("\(viewModel.comboScore.value)X COMBO")
                        .font(.largeTitle)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .scaleEffect(self.viewModel.animateComboScore ? 1.5 : 1.0)
                        .foregroundColor(self.viewModel.animateComboScore ? .red : .black)
                }
            }
        }
        .onReceive(gameLogic.$score, perform: { newScore in
            withAnimation {
                if newScore == 0 {
                    return
                }

                viewModel.increaseScore()
            }
        })
        .onReceive(gameLogic.$comboCounter, perform: { newCombo in
            guard newCombo > 0 else {
                viewModel.resetComboScore()
                return
            }

            viewModel.increaseScore()
        })
        .onReceive(gameLogic.$isMusicFinished) { isFinished in
            withAnimation {
                if isFinished {
                    print("[isFinished]", isFinished)
                    gameLogic.isMusicFinished = false

                    pathStore.navigateToView(routerPath: .finish(viewModel.score))
                }
            }
        }
    }
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView(viewModel: DependencyInjection.init().providePlayViewModel())
    }
}
