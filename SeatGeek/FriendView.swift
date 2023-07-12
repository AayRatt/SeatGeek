import SwiftUI



struct FriendView: View {
    
    let selectedUserIndex : Int
    @EnvironmentObject var dbHelper : FirestoreController
    @State private var userName: String = ""
    @State private var eventAmount: Int = 0
    @AppStorage("loggedUser") var loggedUser: String = ""
    @State private var showAlert:Bool = false
    @State private var showingDeleteAlert:Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color("dark").ignoresSafeArea()
            VStack{
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
                  Text("\(userName) is attending \(self.dbHelper.userEventList.count) Event(s)")
                  .font(.subheadline)
                  Button("Remove Friend") {
                      showingDeleteAlert = true
                  }.buttonStyle(.borderedProminent).foregroundColor(.black)
                  .alert(isPresented: $showingDeleteAlert) {
                    Alert(
                      title: Text("Delete Friend"),
                      message: Text("Are you sure you want to delete this friend?"),
                      primaryButton: .destructive(Text("Delete")) {
                          //TODO: Delete Friend Here
//                          let friendToDelete = dbHelper.friendList[]
//                            dbHelper.deleteFriend(loggedUser: loggedUser, friendToDelete: friendToDelete)
                      },
                      secondaryButton: .cancel()
                    )
                  }
              }
            }.padding(15)
                List {
                    Section(header:Text("events they are attending")){
                        ForEach(self.dbHelper.userEventList, id: \.id) { event in
                            Text(event.venue.name)
                        }
                    }
                }.scrollContentBackground(.hidden)
            
            }
        }
        .onAppear(){
            self.dbHelper.userEventList.removeAll()
            let selectedUser = dbHelper.friendList[selectedUserIndex]
            self.dbHelper.getUserEvents(userEmail: selectedUser.email)
            
            self.userName = selectedUser.name
            
            
            
//            if(self.dbHelper.userEventList.isEmpty){
//                
//                self.eventAmount = 0
//                
//            }else{
//                
//                self.eventAmount =  self.dbHelper.userEventList.count
//            }

            
        }
       
    }
}

//struct UserDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserDetailView()
//    }
//}

