//
//  MyEventsView.swift
//  SeatGeek
//
//  Created by Aayush Rattan on 2023-07-05.
//

import SwiftUI

struct MyEventsView: View {

  @EnvironmentObject var dbHelper: FirestoreController
  @AppStorage("loggedUser") var loggedUser: String = ""
  @State private var showAlert: Bool = false

  @State private var showingDeleteAlert = false
  @State private var showingDeleteAlert2 = false
  @State private var deleteIndexSet: IndexSet?
  @State var mode: EditMode = .inactive

  var body: some View {

    NavigationView {

      VStack {

        Text("Events that you are attending to:")

        List {
          ForEach(self.dbHelper.favEventList, id: \.id) { event in
            HStack {
              NavigationLink(destination: FavoriteEventDetailedView(selectedEvent: event)) {
                Text("\(event.venue.name)")
                  .bold()
              }
            }
          }
          .onDelete(perform: { indexSet in

            deleteIndexSet = indexSet
            showingDeleteAlert = true

          })  //onDelete
        }
        .alert(isPresented: $showingDeleteAlert) {
          Alert(
            title: Text("Remove Event?"),
            message: Text("Are you sure you want to remove this event?"),
            primaryButton: .destructive(Text("Delete")) {
              if let indexSet = deleteIndexSet {
                for index in indexSet {
                  let eventToDelete = dbHelper.favEventList[index]

                  self.dbHelper.deleteEventFromFavorites(
                    loggedUser: self.loggedUser, eventToDelete: eventToDelete)

                  self.dbHelper.deleteAttendee(loggedUser: self.loggedUser, event: eventToDelete) {
                    success, error in

                    if success {

                      print("Success Deleting attendee from event")

                    } else {

                      print("Error Deleting attendee from event")
                    }

                  }

                }
              }

            },
            secondaryButton: .cancel()
          )
        }

        //                Button{
        //
        //                    showingDeleteAlert2 = true
        //
        //                }label: {
        //                    Text("Delete all events from list")
        //                }
        .alert(isPresented: $showingDeleteAlert2) {
          Alert(
            title: Text("Delete All Events From List"),
            message: Text(
              "Are you sure you want to delete all events from your favorite list? This action cannot be undone."
            ),
            primaryButton: .destructive(
              Text("Delete"),
              action: {

                self.dbHelper.deleteAllFavoriteEvents(loggedUser: loggedUser)

                self.dbHelper.deleteAttendeeFromMultipleEvents(loggedUser2: loggedUser)
                self.dbHelper.favEventList.removeAll()

              }),
            secondaryButton: .cancel()
          )
        }

      }
      .onAppear {
        self.dbHelper.favEventList.removeAll()
        self.dbHelper.getMyEvents(loggedUser: loggedUser)
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          EditButton()
        }
        ToolbarItemGroup(placement: .navigationBarLeading) {
          if mode == .active {
            Button {
              showingDeleteAlert2 = true
            } label: {
              Text("Delete All")
            }
          }
        }
      }
      .environment(\.editMode, $mode)

    }

  }
}

struct MyEventsView_Previews: PreviewProvider {
  static var previews: some View {
    MyEventsView()
  }
}
