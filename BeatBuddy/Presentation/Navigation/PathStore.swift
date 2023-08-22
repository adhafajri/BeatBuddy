//
//  PathStore.swift
//  BeatBuddy
//
//  Created by Muhammad Adha Fajri Jonison on 20/08/23.
//

import Foundation
import SwiftUI

class PathStore: ObservableObject {
    @Published var path: NavigationPath = NavigationPath()

    func popToRoot() {
        path = NavigationPath()
    }

    func goBack() {
        guard !path.isEmpty else {
            return
        }

        path.removeLast()
    }

    func navigateToView(routerPath: RouterPath) {
        path.append(routerPath)
    }
}
