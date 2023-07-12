//
//  SearchFriends.swift
//  SeatGeek
//
//  Created by Arnoldo Bermudez on 2023-07-08.
//

import SwiftUI
import FirebaseFirestore

struct SearchFriends: View {
    @State private var friendToSearch = ""
    @EnvironmentObject var dbHelper: FirestoreController
    @State private var searchText = ""

    var searchResults: [User] {
        if searchText.isEmpty {
            return self.dbHelper.userList
        } else {
            return self.dbHelper.userList.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        Text("Search Friends here!")
        VStack {
            List {
                ForEach(searchResults.indices, id: \.self) { index in
                    let user = searchResults[index]
                    
                    NavigationLink(destination: UserDetailView(selectedUser: user).environmentObject(self.dbHelper)) {
                        HStack {
                            Text(user.name)
                                .bold()
                        }
                    }
                }

            }
            .searchable(text: $searchText)
        }
        .onAppear() {
            self.dbHelper.userList.removeAll()
            self.dbHelper.getAllUsers()
        }
    }
}




struct SearchFriends_Previews: PreviewProvider {
    static var previews: some View {
        SearchFriends()
    }
}
