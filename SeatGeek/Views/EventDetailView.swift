//
//  EventDetailView.swift
//  SeatGeek
//
//  Created by Aayush Rattan on 2023-07-09.
//

import SwiftUI

struct EventDetailView: View {
  @State var selectedEvent: Event?
  @State private var showAlert: Bool = false
  @State private var showAlert2: Bool = false
  @EnvironmentObject var dbHelper: FirestoreController
  @AppStorage("loggedUser") var loggedUser: String = ""

  @Environment(\.dismiss) var dismiss

  var body: some View {
    NavigationStack {
      ZStack {
        Image("background")
          .ignoresSafeArea()
        ScrollView {
          AsyncImage(url: URL(string: (selectedEvent?.performers.first?.images.huge)!))
            .frame(height: 350)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))

          VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
              Text((selectedEvent?.venue.name)!)
                .font(.system(size: 29, weight: .semibold, design: .default))
              Spacer()
            }
            Text((selectedEvent?.venue.city)!)
              .font(.system(.callout, weight: .medium))
            Text((selectedEvent?.venue.address)!)
              .font(.system(.body))
              .padding(.vertical)

            Text((selectedEvent?.datetimeUtc)!)
          }
          .padding(.horizontal, 24)
          .padding(.top, 12)
          //
          VStack(spacing: 14) {
            HStack {
              Button("Add to My Events") {
                //TODO: Add to Event List

                self.dbHelper.checkExistingEventinFavorites(
                  currentuser: self.loggedUser, event: selectedEvent!
                ) { exists, error in
                  if let error = error {
                    // Handle error
                    print(
                      "Error checking existing event in favorites: \(error.localizedDescription)")
                  } else if exists {
                    showAlert2 = true
                  } else {
                    self.dbHelper.checkExistingEvent(event: selectedEvent!) { exists, error in
                      if let error = error {
                        // Handle error
                        print("Error checking existing event: \(error.localizedDescription)")
                      } else {
                        if exists {
                          do {
                            try self.dbHelper.addEventToFavorites(
                              loggedUser: loggedUser, event: selectedEvent!
                            ) { success, error in

                              if success {
                                print("Success adding event to favorites")
                                showAlert = true
                                dismiss()
                              } else {
                                print("Error adding event to favorites")
                              }
                            }
                            try self.dbHelper.addUserToEventAtendeeList(
                              userToAdd: self.loggedUser, event: selectedEvent!
                            ) { success, error in
                              if success {
                                print("Success adding user to event attendee list")
                                showAlert = true
                                dismiss()
                              } else {
                                print("Error adding user to event attendee list")
                              }
                            }
                          } catch {
                          }
                        } else {
                          // Event does not exist, proceed with creating it
                          self.dbHelper.createEvent(eventToCreate: selectedEvent!)
                          do {
                            try self.dbHelper.addEventToFavorites(
                              loggedUser: loggedUser, event: selectedEvent!
                            ) { success, error in
                              if success {
                                print("Success adding event to favorites")
                                showAlert = true
                                dismiss()
                              } else {
                                print("Error adding event to favorites")
                              }
                            }
                            try self.dbHelper.addUserToEventAtendeeList(
                              userToAdd: self.loggedUser, event: selectedEvent!
                            ) { success, error in
                              if success {
                                print("Success adding user to event attendee list")
                                showAlert = true
                                dismiss()
                              } else {
                                print("Error adding user to event attendee list")
                              }
                            }
                          } catch {
                          }
                        }
                      }
                    }
                  }
                }
              }
              .alert("Event Added to Favorites", isPresented: $showAlert) {}
              .alert("Couldn't add event, already in favorites", isPresented: $showAlert2) {}
              .buttonStyle(GrowingButton(width: 300))
              .padding()
            }.buttonStyle(GrowingButton(width: 300))
            List {
              Text("TEST")
            }
          }
          .ignoresSafeArea()
          .padding(.vertical, 28)
          .padding(.bottom, 55)
          List {
            ForEach(self.dbHelper.friendsAttendingSameEvent, id: \.email) { friend in
              Text(friend.name)
            }.listStyle(InsetGroupedListStyle())
              .frame(height: 200)
          }
        }
      }.onAppear {
        self.dbHelper.friendsAttendingSameEvent.removeAll()
        self.dbHelper.getFriendsWhoAreAttendingSameEvent(event: selectedEvent!)
      }
    }
  }
}
