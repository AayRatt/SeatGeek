import SwiftUI

struct UserDetailView: View {
    let selectedUser: User
    @EnvironmentObject var dbHelper: FirestoreController
    @State private var userName: String = ""
    @State private var eventAmount: Int = 0
    @AppStorage("loggedUser") var loggedUser: String = ""
    @State private var showAlert: Bool = false
    @State private var closestEvent = ""

    var body: some View {
        
        
            VStack {
                Text(userName)
                Text("This user is attending \(self.dbHelper.userEventList.count) events!")
                
                Text("User's Next Event is:\(self.closestEvent)")
                
                List{
                    if(self.dbHelper.friendsAttendingSameEvent.isEmpty){
                        
                        Text("None of your friends are attending this event")
                    }else{
                        
                        if(self.dbHelper.friendsAttendingSameEvent.count == 1 && self.dbHelper.friendsAttendingSameEvent[0].email == selectedUser.email){
                            
                            Text("None of your friends are attending this event")
                            
                        }else{
                            
                            Text("Friends attending this event:")
                            
                            ForEach(self.dbHelper.friendsAttendingSameEvent.indices, id:\.self) {index in
                                
                                let friend = self.dbHelper.friendsAttendingSameEvent[index]
                                
                                if(friend.name == userName){
                                    
                                }else{
                                    
                                    Text("\(friend.name)")
                                    
                                }
                                
                                
                                
                            }
                            
                        }
                        
                        
                        
                    }
                }
                
                
                Button {
                    var newFriend = User(name: selectedUser.name, email: selectedUser.email)
                    
                    do {
                        try self.dbHelper.addFriend(loggedUser: self.loggedUser, friend: newFriend) { success, error in
                            if success {
                                print("Success adding friend")
                                showAlert = true
                                //presentationMode.wrappedValue.dismiss()
                            } else {
                                print("Error adding friend")
                            }
                        }
                    } catch {
                        // Handle error
                    }
                } label: {
                    Text("Add Friend")
                }
                .alert("Friend Added!", isPresented: $showAlert) {
                    // Alert content
                }
            }
            .onAppear() {
                self.dbHelper.userEventList.removeAll()
                self.dbHelper.friendsAttendingSameEvent.removeAll()
                self.dbHelper.userClosestEvent = ""
                self.dbHelper.getUserEvents(userEmail: selectedUser.email)
                
                self.dbHelper.getSingleUser(email: selectedUser.email) { user in
                    if user == nil {
                        userName = "ERROR FETCH USERNAME"
                    } else {
                        userName = user!.name
                    }
                }
                
                self.dbHelper.getUserClosestEvent(userEmail:selectedUser.email){closestEvent in
                    if let event = closestEvent {
                        
                        self.closestEvent = event.venue.name
                        
                        self.dbHelper.getFriendsWhoAreAttendingSameEvent(event: event)
                        
                    } else {
                        
                        self.closestEvent = "User does not have events soon"
                    }
                    
                }
                
                
                
            }
        
    }
}

