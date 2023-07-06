//
//  EventsView.swift
//  SeatGeek
//
//  Created by Aayush Rattan on 2023-07-05.
//

import SwiftUI

struct EventsView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @EnvironmentObject var authHelper:FirebaseAuthController
    var body: some View {
        NavigationStack {
            Button("Sign Out") {
                isLoggedIn = false
                authHelper.signOut()
            }
        }
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView()
    }
}
