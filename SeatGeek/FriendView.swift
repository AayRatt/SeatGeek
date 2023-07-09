import SwiftUI

struct FriendView: View {
    
    let selectedUserIndex : Int
    @EnvironmentObject var dbHelper : FirestoreController
    @State private var userName: String = ""
    @AppStorage("loggedUser") var loggedUser: String = ""
    @State private var showAlert:Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        VStack{
            Text(userName)
            
            Button{
                
//                do{
//                    try self.dbHelper.addFriend(loggedUser: self.loggedUser, friend:newFriend ){ succes, error in
//
//                        if succes{
//                            print("Success adding friend")
//                            showAlert = true
//                            dismiss()
//
//                        }else{
//                            print("Error adding friend")
//                        }
//
//
//                    }
//                }catch{
//
//                }
            }label: {
                Text("Remove From Friends")
            }
            .alert("Friend Removed!", isPresented: $showAlert){ }
        }
        .onAppear(){
            let selectedUser = dbHelper.friendList[selectedUserIndex]
            
            self.userName = selectedUser.name
        }
       
    }
}

//struct UserDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserDetailView()
//    }
//}

