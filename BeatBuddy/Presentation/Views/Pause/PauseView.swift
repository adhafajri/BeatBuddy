//
//  PauseView.swift
//  BeatBuddy
//
//  Created by Muhammad Adha Fajri Jonison on 15/08/23.
//

import SwiftUI

struct PauseView: View {
    @EnvironmentObject private var pathStore: PathStore
    @StateObject private var gameLogic = GameLogic()

    var body: some View {
        VStack {
            PrimaryButton(buttonImage: .play, text: "Resume") {
                gameLogic.startGame()
                pathStore.goBack()
            }

            PrimaryButton(buttonImage: .reset, text: "Reset") {
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

struct PauseView_Previews: PreviewProvider {
    static var previews: some View {
        PauseView()
    }
}
