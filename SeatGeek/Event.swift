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

struct Event: Codable {
    let type: String
    let datetimeUtc: String
    let venue: Venue

    
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
}
