//
//  SeatGeekApp.swift
//  SeatGeek
//
//  Created by Aayush Rattan on 2023-07-05.
//

import SwiftUI
import Firebase
import FirebaseAuth

@main
struct SeatGeekApp: App {
    let persistenceController = PersistenceController.shared

    let authHelper = FirebaseAuthController()

    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(authHelper)
        }
    }
}
