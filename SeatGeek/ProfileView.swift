//
//  ProfileView.swift
//  SeatGeek
//
//  Created by Aayush Rattan on 2023-07-08.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authHelper:FirebaseAuthController
    @EnvironmentObject var dbHelper : FirestoreController
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("loggedUser") var loggedUser: String = ""
    
    @State private var showingDeleteAlert = false
    @State private var deleteIndexSet: IndexSet?

    
    var body: some View {
            NavigationView {
                VStack {
                    List {
                        Section(header: Text("My Details")) {
                            
                        }
                        
                        Section(header: Text("Friends List")) {
                            
                            ForEach(self.dbHelper.friendList.enumerated().map({$0}), id: \.element.self){index, user in
                            
                            
                                NavigationLink{
                                    
                                    FriendView(selectedUserIndex: index).environmentObject(self.dbHelper)

                                }label:{
                                    HStack{
                                        
                                        Text(" \(user.name)")
                                            .bold()
                                        
                                    }//HStack
                                }//Navigation Link
                                
                            }//ForEach
                            .onDelete(perform: { indexSet in
                                
                                deleteIndexSet = indexSet
                                showingDeleteAlert = true

                            })//onDelete
                            
                        }
                    }
                    .alert(isPresented: $showingDeleteAlert) {
                        Alert(
                            title: Text("Delete Friend"),
                            message: Text("Are you sure you want to delete this friend?"),
                            primaryButton: .destructive(Text("Delete")) {
                                if let indexSet = deleteIndexSet {
                                    for index in indexSet {
                                        let friendToDelete = dbHelper.friendList[index]
                                        dbHelper.deleteFriend(loggedUser: loggedUser, friendToDelete: friendToDelete)
                                    }
                                }
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    
                    Spacer()
                }

                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isLoggedIn = false
                            authHelper.signOut()
                        }) {
                            Text("Sign Out")
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        NavigationLink(destination:SearchFriends()) {
                            Image(systemName: "magnifyingglass")
                            Text("Search Friends")
                        }
                    }
                }
                .onAppear(){
                    self.dbHelper.friendList.removeAll()
                    self.dbHelper.getMyFriends(loggedUser: self.loggedUser)
                }
            }
        }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
