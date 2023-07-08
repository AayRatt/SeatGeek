//
//  ProfileView.swift
//  SeatGeek
//
//  Created by Aayush Rattan on 2023-07-08.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authHelper:FirebaseAuthController
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    var body: some View {
        Button("Sign Out") {
            isLoggedIn = false
            authHelper.signOut()
        }
        
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
