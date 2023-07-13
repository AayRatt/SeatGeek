import SwiftUI

struct UserDetailView: View {
    let selectedUser: User
    @EnvironmentObject var dbHelper: FirestoreController
    @State private var userName: String = ""
    @State private var eventAmount: Int = 0
    @AppStorage("loggedUser") var loggedUser: String = ""
    @State private var showAlert: Bool = false
    @State private var showAlert2: Bool = false
    @State private var closestEvent = ""
    
    private var imageURL:String {
        
        let formattedString = userName.replacingOccurrences(of: " ", with: "")
        
        return "https://api.multiavatar.com/\(formattedString).png?apikey=wYVkEXCNObPTpM"
    }

    var body: some View {
        
        
            ZStack {
                Color("dark").ignoresSafeArea()
                VStack {
                    HStack {
                        
                        AsyncImage(url: URL(string: imageURL)) { phase in
                            switch phase {
                            case .empty:
                                // Placeholder view or loading indicator
                                Color.gray
                            case .success(let image):
                                // Use the image view
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: 90, maxHeight: 90)
                                    .clipShape(Circle())
                            case .failure:
                                // Error view
                                Color.red
                            }
                        }
//                      Image(systemName: "person.circle")
//                        .resizable()
//                        .frame(width: 90, height: 90)
//                        .clipShape(Circle())
                      Spacer().frame(width: 30)
                      VStack {
                        Text(userName)
                          .font(.title)
                          .bold()
                          Text("\(userName) is attending \(self.dbHelper.userEventList.count) Event(s)")
                          .font(.subheadline)
                          Button(action: {
                              var newFriend = User(name: selectedUser.name, email: selectedUser.email)
                              
                              self.dbHelper.checkExistingFriend(loggedUser: self.loggedUser, friend: newFriend) { exists, error in
                                  if let error = error {
                                      // Handle error
                                      print("Error checking existing friend: \(error.localizedDescription)")
                                  }
                                  
                                  if exists {
                                      showAlert2 = true
                                  } else {
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
                                  }
                              }
                          }) {
                              if showAlert2 {
                                  Text("You are already friends with this user")
                                      .foregroundColor(.black)
                              } else {
                                  Text("Add Friend")
                                      .foregroundColor(.black)
                              }
                          }
                          .buttonStyle(.borderedProminent)
                          .alert(isPresented: $showAlert) {
                              Alert(title: Text("Friend Added!"), message: nil, dismissButton: .default(Text("OK")))
                          }
                          .disabled(showAlert2)

//                          .buttonStyle(.borderedProminent)
//                          .alert("Friend Added!", isPresented: $showAlert) {
//                              // Alert content
//                          }
//                          .disabled(showAlert2)


                      }
                    }.padding(15)
                    List {
                        Section(header: Text("Next event attending:")) {
                                Text(closestEvent)
                        }
                    }.scrollContentBackground(.hidden)
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
                    }.scrollContentBackground(.hidden)
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

