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
    @State private var eventAmount: Int = 0
    @AppStorage("loggedUser") var loggedUser: String = ""
    @State private var showAlert:Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        VStack{
            Text(userName)
            Text("This user is attending\(self.eventAmount) events!")
            
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
            
            self.dbHelper.userEventList.removeAll()
            self.dbHelper.getUserEvents(userEmail: selectedUser.email)
            
            self.eventAmount = self.dbHelper.userEventList.count
            
            self.dbHelper.getSingleUser(email: selectedUser.email){user in
                
                if(user == nil){

                    userName = "ERROR FETCH USERNAME"
                }else{

                    userName = user!.name
                }


            }
        }
       
    }
}

//struct UserDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserDetailView()
//    }
//}
