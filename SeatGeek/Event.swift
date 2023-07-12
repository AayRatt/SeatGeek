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

struct Event: Codable, Identifiable{
    var id:Int
    let type: String
    let datetimeUtc: String
    let venue: Venue
    let performers: [Performers]
    let stats:Stats?

    
    struct Venue: Codable {
        let state: String?
        let postalCode: String
        let name: String
        let location: Location
        let address: String?
        let country: String?
        let city: String?
        
        struct Location: Codable {
            let lat: Double?
            let lon: Double?
        }
    }
    
    struct Performers:Codable {
        let images:Image
    }
    
    struct Image:Codable {
        let huge:String
    }
    
    struct Stats:Codable {
        let averagePrice:Int?
    }
    
}
