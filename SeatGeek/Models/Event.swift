//
//  Event.swift
//  SeatGeek
//
//  Created by Aayush Rattan on 2023-07-06.
//

import Foundation

struct EventResponse: Codable {
    let events: [Event]
}

struct Event: Codable, Identifiable, Hashable{
    var id:Int
    let type: String
    let datetimeUtc: String
    let venue: Venue
    let performers: [Performers]
    let stats:Stats?

    
    struct Venue: Codable, Hashable {
        let state: String?
        let postalCode: String
        let name: String
        let location: Location
        let address: String?
        let country: String?
        let city: String?
        
        struct Location: Codable, Hashable  {
            let lat: Double?
            let lon: Double?
        }
    }
    
    struct Performers:Codable, Hashable  {
        let images:Image
    }
    
    struct Image:Codable, Hashable  {
        let huge:String
    }
    
    struct Stats:Codable, Hashable  {
        let averagePrice:Int?
    }
    
}
