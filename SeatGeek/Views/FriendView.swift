import SwiftUI

struct FriendView: View {

  let selectedUserIndex: Int
  @EnvironmentObject var dbHelper: FirestoreController
  @State private var userName: String = ""
  @State private var eventAmount: Int = 0
  @AppStorage("loggedUser") var loggedUser: String = ""
  @State private var showAlert: Bool = false
  @State private var showingDeleteAlert: Bool = false

  private var imageURL: String {

    let formattedString = userName.replacingOccurrences(of: " ", with: "")

    return "https://api.multiavatar.com/\(formattedString).png?apikey=wYVkEXCNObPTpM"
  }

  @Environment(\.dismiss) var dismiss

  var body: some View {
    ZStack {
      Color("dark").ignoresSafeArea()
      VStack {
        HStack {
          AsyncImage(url: URL(string: imageURL)) { phase in
            switch phase {
            case .empty:
              // Placeholder view or loading indicator
              Image(systemName: "person.circle")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: 90, maxHeight: 90)
                .clipShape(Circle())
            case .success(let image):
              // Use the image view
              image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: 90, maxHeight: 90)
                .clipShape(Circle())
            case .failure:
              // Error view
              Image(systemName: "person.circle")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: 90, maxHeight: 90)
                .clipShape(Circle())
            }
          }

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
                    let selectedUser = dbHelper.friendList[selectedUserIndex]
                    dbHelper.deleteFriend(loggedUser: loggedUser, friendToDelete: selectedUser)
                    dismiss()
                  },
                  secondaryButton: .cancel()
                )
              }
          }
        }.padding(15)
        List {
          Section(header: Text("events they are attending")) {
            ForEach(self.dbHelper.userEventList, id: \.id) { event in
              Text(event.venue.name)
            }
          }
        }.scrollContentBackground(.hidden)

      }
    }
    .onAppear {
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
