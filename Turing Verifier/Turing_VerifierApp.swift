//
//  Turing_VerifierApp.swift
//  Turing Verifier
//
//  Created by Seamus Grealey on 12/2/22.
//

import SwiftUI

@main
struct Turing_VerifierApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
