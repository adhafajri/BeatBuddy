//
//  PrimaryButton.swift
//  BeatBuddy
//
//  Created by Muhammad Adha Fajri Jonison on 20/08/23.
//

import SwiftUI

struct PrimaryButton: View {
    var buttonImage: ButtonImage
    var text: String

    let onClick: () -> Void

    var body: some View {
        Button {
            onClick()
        } label: {
            HStack {
                Image(systemName: buttonImage.rawValue)
                Text(text)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .padding(.horizontal)
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryButton(buttonImage: ButtonImage.play, text: "test", onClick: {})
    }
}
