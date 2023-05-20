//
//  pc1App.swift
//  pc1
//
//  Created by Muhammad Adha Fajri Jonison on 20/05/23.
//

import SwiftUI

@main
struct pc1App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
