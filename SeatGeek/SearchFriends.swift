import SwiftUI
import FirebaseFirestore

struct SearchFriends: View {
    @State private var friendToSearch = ""
    @EnvironmentObject var dbHelper: FirestoreController
    @State private var searchText = ""

    var searchResults: [User] {
        if searchText.isEmpty {
            return self.dbHelper.userList
        } else {
            return self.dbHelper.userList.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        
        
        NavigationView{
            VStack {
                Text("Search Friends here!")
                List(searchResults, id: \.self) { user in
                    NavigationLink(destination: UserDetailView(selectedUser: user).environmentObject(self.dbHelper)) {
                        Text(user.name)
                            .bold()
                    }
                    
                }
                .searchable(text: $searchText)
            }
            .onAppear() {
                if self.dbHelper.userList.isEmpty {
                    self.dbHelper.getAllUsers()
                }
            }
        }
        
        
        
    }
}

struct SearchFriends_Previews: PreviewProvider {
    static var previews: some View {
        SearchFriends()
    }
}
