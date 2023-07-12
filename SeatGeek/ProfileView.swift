//
//  ProfileView.swift
//  SeatGeek
//
//  Created by Aayush Rattan on 2023-07-08.
//

import SwiftUI

struct ProfileView: View {
  @EnvironmentObject var authHelper: FirebaseAuthController
  @EnvironmentObject var dbHelper: FirestoreController
  @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
  @AppStorage("loggedUser") var loggedUser: String = ""

  @State private var showingDeleteAlert = false
  @State private var deleteIndexSet: IndexSet?
  @State private var userName: String = "Lorem Ipsum"

  var body: some View {
    NavigationView {
      VStack {
        HStack {
          Image(systemName: "person.circle")
            .resizable()
            .frame(width: 90, height: 90)
            .clipShape(Circle())
          Spacer().frame(width: 30)
          VStack {
            Text(userName)
              .font(.title)
              .bold()
              Text("You are attending \(self.dbHelper.favEventList.count) Event(s)")
              .font(.subheadline)
          }
        }.padding(15)
        List {
          Section(header: Text("Friends List")) {

              ForEach(self.dbHelper.friendList.indices, id: \.self) { index in
                  let user = self.dbHelper.friendList[index]
                  
                  NavigationLink(destination: FriendView(selectedUserIndex: index).environmentObject(self.dbHelper)) {
                      HStack {
                          Text("\(user.name)")
                              .bold()
                      }
                  }
              }

            .onDelete(perform: { indexSet in

              deleteIndexSet = indexSet
              showingDeleteAlert = true

            })  //onDelete

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
          NavigationLink(destination: SearchFriends()) {
            Image(systemName: "magnifyingglass")
            Text("Search Friends")
          }
        }
      }
      .onAppear {
        self.dbHelper.friendList.removeAll()
        self.dbHelper.getMyFriends(loggedUser: self.loggedUser)
        self.dbHelper.getSingleUser(email: self.loggedUser){user in
            
            if(user == nil){

                userName = "ERROR FETCH USERNAME"
            }else{

                userName = user!.name
            }


        }
      }
    }
  }
}

struct ProfileView_Previews: PreviewProvider {
  static var previews: some View {
    ProfileView()
  }
}
