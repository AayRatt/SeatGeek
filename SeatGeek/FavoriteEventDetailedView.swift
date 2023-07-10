//
//  FavoriteEventDetailedView.swift
//  SeatGeek
//
//  Created by Arnoldo Bermudez on 2023-07-09.
//

import SwiftUI

struct FavoriteEventDetailedView: View {
    @State var selectedEvent: Event?
    @EnvironmentObject var dbHelper : FirestoreController
    
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
          }
        }
      }
    }
}

struct FavoriteEventDetailedView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteEventDetailedView()
    }
}
