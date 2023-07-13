//
//  MainView.swift
//  SeatGeek
//
//  Created by Aayush Rattan on 2023-07-05.
//

import SwiftUI

struct MainView: View {
  @EnvironmentObject var dbHelper: FirestoreController

  var body: some View {
    TabView {
      EventsView()
        .tabItem {
          Label("Events", systemImage: "mappin.square.fill")
        }
      MyEventsView()
        .tabItem {
          Label("My Events", systemImage: "list.star")
        }
      ProfileView()
        .tabItem {
          Label("My Profile", systemImage: "person.crop.circle.fill")
        }
    }
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}
