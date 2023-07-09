//
//  MyEventsView.swift
//  SeatGeek
//
//  Created by Aayush Rattan on 2023-07-05.
//

import SwiftUI

struct MyEventsView: View {
    
    @EnvironmentObject var dbHelper : FirestoreController
    @AppStorage("loggedUser") var loggedUser: String = ""
    @State private var showAlert:Bool = false
    
    @State private var showingDeleteAlert = false
    @State private var deleteIndexSet: IndexSet?
    
    //@Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        NavigationView{
            
            VStack{
                
                List {
                    ForEach(self.dbHelper.favEventList.indices, id: \.self) { index in
                        let event = self.dbHelper.favEventList[index]
                        //NavigationLink(destination: EventDetailView(event: event)) {
                            HStack {
                                Text("\(event.venue.name)")
                                    .bold()
                            }
                        //}
                    }
                    .onDelete(perform: { indexSet in
                        
                        deleteIndexSet = indexSet
                        showingDeleteAlert = true

                    })//onDelete
                }
                .alert(isPresented: $showingDeleteAlert) {
                    Alert(
                        title: Text("Remove Event?"),
                        message: Text("Are you sure you want to remove this event?"),
                        primaryButton: .destructive(Text("Delete")) {
                            if let indexSet = deleteIndexSet {
                                for index in indexSet {
                                    let eventToDelete = dbHelper.favEventList[index]
                                    
                                    self.dbHelper.deleteEventFromFavorites(loggedUser: self.loggedUser, eventToDelete: eventToDelete)
                                    
                                    //dismiss()
                                }
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }

                
                
                let dummyEvent = Event(type: "Sports Game", datetimeUtc: "2023-07-20T18:30:00", venue: Event.Venue(state: "Texas", postalCode: "77002", name: "Sports Arena", location: Event.Venue.Location(lat: 29.7604, lon: -95.3698), address: "789 Main St", country: "United States", city: "Houston"))


                Button{
                    
                    self.dbHelper.checkExistingEvent(event: dummyEvent) {exists, error in
                        if let error = error {
                            // Handle error
                            print("Error checking existing event: \(error.localizedDescription)")
                        }else {
                            if exists {
                                
                                do{
                                    
                                    try self.dbHelper.addEventToFavorites(loggedUser: loggedUser, event: dummyEvent){ success, error in
                                        
                                        if success{
                                            print("Success adding event to favorites")
                                            showAlert = true
                            
                                            
                                        }else{
                                            print("Error adding event to favorites")
                                        }
                                        

                                    }
                                    
                                    
                                    
                                }catch{
                                    
                                }
                                
                                
                                
                            }else {
                                // Event does not exist, proceed with creating it
                                self.dbHelper.createEvent(eventToCreate: dummyEvent)
                            }
                            
                            
                        }
                    }
                    
                }label: {
                    Text("Add To favorites")
                }
                .alert("Event Added!", isPresented: $showAlert){ }
                
            }
            .onAppear(){
                self.dbHelper.favEventList.removeAll()
                self.dbHelper.getMyEvents(loggedUser: loggedUser)
            }
            
            
            
        }

    }
}

struct MyEventsView_Previews: PreviewProvider {
    static var previews: some View {
        MyEventsView()
    }
}
