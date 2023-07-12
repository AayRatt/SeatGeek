import SwiftUI



struct FriendView: View {
    
    let selectedUserIndex : Int
    @EnvironmentObject var dbHelper : FirestoreController
    @State private var userName: String = ""
    @State private var eventAmount: Int = 0
    @AppStorage("loggedUser") var loggedUser: String = ""
    @State private var showAlert:Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
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
          }
        }.padding(15)
        
        
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

