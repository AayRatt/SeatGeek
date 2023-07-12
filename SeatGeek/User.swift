import Foundation
import FirebaseFirestoreSwift

struct User: Codable{
    

    var name: String
    var email: String
    var events: [Event]?

    init(name: String, email: String, events: [Event]? = nil) {
        self.email = email
        self.name = name
        self.events = events
    }

    init?(dictionary: [String: Any]) {
        guard let name = dictionary["name"] as? String else {
            print(#function, "Unable to get user name from JSON")
            return nil
        }

        guard let email = dictionary["email"] as? String else {
            print(#function, "Unable to get email from JSON")
            return nil
        }

        if let events = dictionary["events"] as? [Event] {
            self.init(name: name, email: email, events: events)
        } else {
            self.init(name: name, email: email)
        }
    }
}
