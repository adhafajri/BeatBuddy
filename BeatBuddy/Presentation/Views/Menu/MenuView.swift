//
//  MenuView.swift
//  pc1
//
//  Created by Muhammad Adha Fajri Jonison on 15/08/23.
//

import SwiftUI

struct MenuView: View {
    @EnvironmentObject private var pathStore: PathStore
    @StateObject private var viewModel: MenuViewModel

    init(viewModel: MenuViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            Image("logo")
                .resizable()
                .scaledToFit()
                .padding(.horizontal)

            Text("BEATBUDDY")
                .font(.largeTitle)
                .fontWeight(.light)
                .padding(.horizontal)

            Spacer().fixedSize().padding()

            if viewModel.highScore > 0 {
                Text("HIGH SCORE: \(viewModel.highScore)")
            }

            PrimaryButton(buttonImage: .play, text: "Play") {
                pathStore.navigateToView(routerPath: .play)
            }

            PrimaryButton(buttonImage: .exit, text: "Exit") {
                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
            }
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView(viewModel: DependencyInjection.init().provideMenuViewModel())
    }
}
