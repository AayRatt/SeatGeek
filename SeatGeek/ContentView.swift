//
//  ContentView.swift
//  SeatGeek
//
//  Created by Aayush Rattan on 2023-07-05.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @AppStorage("isLoggedIn") var isLoggedIn:Bool = false
    
    private var dbHelper = FirestoreController.getInstance()
    
    var body: some View {
        if isLoggedIn {
            MainView().environmentObject(self.dbHelper)
        } else {
            LoginView()
        }
    }
}
