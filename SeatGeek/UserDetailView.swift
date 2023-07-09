//
//  UserDetailView.swift
//  SeatGeek
//
//  Created by Arnoldo Bermudez on 2023-07-08.
//

import SwiftUI

struct UserDetailView: View {
    
    //let selectedUserIndex : Int
    let selectedUser:User
    @EnvironmentObject var dbHelper : FirestoreController
    @State private var userName: String = ""
    @AppStorage("loggedUser") var loggedUser: String = ""
    @State private var showAlert:Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        VStack{
            Text(userName)
            
            Button{
                var newFriend = User(name:selectedUser.name , email: selectedUser.email)
                
                do{
                    try self.dbHelper.addFriend(loggedUser: self.loggedUser, friend:newFriend ){ succes, error in
                        
                        if succes{
                            print("Success adding friend")
                            showAlert = true
                            dismiss()
                            
                        }else{
                            print("Error adding friend")
                        }
                        
                        
                    }
                }catch{
                    
                }
            }label: {
                Text("Add Friend")
            }
            .alert("Friend Added!", isPresented: $showAlert){ }
        }
        .onAppear(){
            
            self.userName = selectedUser.name
        }
       
    }
}

//struct UserDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserDetailView()
//    }
//}
