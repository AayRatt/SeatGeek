//
//  SearchFriends.swift
//  SeatGeek
//
//  Created by Arnoldo Bermudez on 2023-07-08.
//

import SwiftUI
import FirebaseFirestore

struct SearchFriends: View {
    @State private var friendToSearch = ""
    @EnvironmentObject var dbHelper : FirestoreController
    @State private var searchText = ""
    
    var searchResults: [User] {

        if searchText.isEmpty{

            return self.dbHelper.userList

        }else{
            
            return self.dbHelper.userList.filter{$0.name.localizedCaseInsensitiveContains(searchText)}

        }
    }
    
    var body: some View {
        Text("Search Your Friends here!")
        VStack{
            
            List{
                ForEach(searchResults.enumerated().map({$0}), id: \.element.self){index, user in
                
                
                    NavigationLink{
                        
                        UserDetailView(selectedUserIndex: index).environmentObject(self.dbHelper)
    //                    ParkingDetailView(selectedParkingIndex: index).environmentObject(self.dbHelper)
                    }label:{
                        HStack{
                            
                            Text(" \(user.name)")
                                .bold()
                            
                        }//HStack
                    }//Navigation Link
                    
                }//ForEach
                .onDelete(perform: { indexSet in

    //                for index in indexSet{
    //
    //                    //get the employee object to delete
    //                    let parking = self.dbHelper.parkList[index]
    //
    //                    //delete the document from database
    //                    self.dbHelper.deleteParking(parkingToDelete: parking)
    //                }

                })//onDelete
            }//List
            .searchable(text: $searchText)
        }
        .onAppear(){
            self.dbHelper.userList.removeAll()
            self.dbHelper.getAllUsers()
        }
       
        
        
        
    }
    
    
    



}



struct SearchFriends_Previews: PreviewProvider {
    static var previews: some View {
        SearchFriends()
    }
}
