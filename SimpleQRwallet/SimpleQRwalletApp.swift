//
//  SimpleQRwalletApp.swift
//  SimpleQRwallet
//
//  Created by Bastiaan Quast on 11/4/24.
//

import SwiftUI

@main
struct SimpleQRwalletApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
