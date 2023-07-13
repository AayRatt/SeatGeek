import Foundation
import FirebaseFirestore
import FirebaseAuth


class FirestoreController : ObservableObject{
    
    @Published var userList = [User]()
    @Published var friendList = [User]()
    @Published var favEventList = [Event]()
    @Published var userEventList = [Event]()
    @Published var friendsAttendingSameEvent = [User]()
    var userClosestEvent = ""
    
    
    private let COLLECTION_USERS = "users"
    private let COLLECTION_FRIENDS = "friends"
    private let COLLECTION_EVENTS = "events"
    private let COLLECTION_ATTENDEES = "attendees"
    
    private let db : Firestore
    private static var shared : FirestoreController?
    
    init(db : Firestore){
        self.db = db
    }
    
    //singleton instance
    static func getInstance() -> FirestoreController{
        if (self.shared == nil){
            self.shared = FirestoreController(db: Firestore.firestore())
        }
        
        return self.shared!
    }
    
    
    func getAllUsers(loggedUser:String){
    print(#function, "Trying to get all Users.")
            do{
                
                self.db
                    .collection(COLLECTION_USERS)
                    .addSnapshotListener({ (querySnapshot, error) in
                        
                        guard let snapshot = querySnapshot else{
                            print(#function, "Unable to retrieve data from database : \(error)")
                            return
                        }
                        
                        snapshot.documentChanges.forEach{ (docChange) in
                            
                            do{
                                //convert JSON document to swift object
                                var user : User = try docChange.document.data(as: User.self)
                                
                                //get the document id so that it can be used for updating and deleting document
                                //var documentID = docChange.document.documentID
                                
                                //set the document id to the converted object
                                //user.id = documentID
                                
                                //if new document added, perform required operations
                                if docChange.type == .added{
                                    
                                    if(user.email == loggedUser){
                                        
                                        print(#function, "Logged User : \(user.name), not added")
                                    }else{
                                        
                                        self.userList.append(user)
                                        print(#function, "New document added : \(user.name)")
                                    }
                                   
                                }
                                
                                //if a document deleted, perform required operations
                                if docChange.type == .removed{
                                    print(#function, " document removed : \(user.name)")
                                }
                                
                                //if a document updated, perform required operations
                                if docChange.type == .modified{
                                    
                                    print(#function, " document updated : \(user.name)")
                                }
                                
                            }catch let err as NSError{
                                print(#function, "Unable to convert the JSON doc into Swift Object : \(err)")
                            }
                            
                        }//ForEach
                        
                    })//addSnapshotListener
                
            }catch let err as NSError{
                print(#function, "Unable to get all employee from database : \(err)")
            }
        }
    
    func checkExistingFriend(loggedUser:String, friend: User, completion: @escaping (Bool, Error?) -> Void) {
        
        let eventsCollectionRef = db.collection(COLLECTION_USERS).document(loggedUser).collection(COLLECTION_FRIENDS)

        // Build the query to search for events with matching criteria
        let query = eventsCollectionRef
            .whereField("email", isEqualTo: friend.email)
            .whereField("name", isEqualTo: friend.name)

        // Execute the query
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error checking existing event: \(error)")
                completion(false, error)
                return
            }

            guard let querySnapshot = querySnapshot else {
                print("No existing events found")
                completion(false, nil)
                return
            }

            if !querySnapshot.isEmpty {
                // Event already exists
                print("Event already exists")
                completion(true, nil)
            } else {
                // Event does not exist
                print("Event does not exist")
                completion(false, nil)
            }
        }
    }

    func addFriend(loggedUser:String, friend: User, completion: @escaping (Bool, Error?) -> Void) throws {
        print(#function, "Inserting User to friendsList \(friend)")
        
        do {
            try self.db.collection(COLLECTION_USERS)
                .document(loggedUser)
                .collection(COLLECTION_FRIENDS)
                .addDocument(from: friend) { error in
                    if let error = error {
                        print(#function, "Unable to add friend to user: \(error)")
                        completion(false, error)
                    } else {
                        print(#function, "Friend Added")
                        completion(true, nil)
                    }
                }
        } catch let err {
            print(#function, "Unable to add friend to database: \(err)")
            completion(false, err)
        }
    }
    
    func getMyFriends(loggedUser:String){
    print(#function, "Trying to get all user's friends.")
            do{
                
                self.db
                    .collection(COLLECTION_USERS)
                    .document(loggedUser)
                    .collection(COLLECTION_FRIENDS)
                    .addSnapshotListener({ (querySnapshot, error) in
                        
                        guard let snapshot = querySnapshot else{
                            print(#function, "Unable to retrieve data from database : \(error)")
                            return
                        }
                        
                        snapshot.documentChanges.forEach{ (docChange) in
                            
                            do{
                                //convert JSON document to swift object
                                var user : User = try docChange.document.data(as: User.self)
                                
                                //get the document id so that it can be used for updating and deleting document
                                //var documentID = docChange.document.documentID
                                
                                //set the document id to the converted object
                                //user.id = documentID
                                
                                //if new document added, perform required operations
                                if docChange.type == .added{
                                    self.friendList.append(user)
                                    print(#function, "New document added : \(user.name)")
                                }
                                
                                //if a document deleted, perform required operations
                                if docChange.type == .removed{
                                    print(#function, " document removed : \(user.name)")
                                }
                                
                                //if a document updated, perform required operations
                                if docChange.type == .modified{
                                    
                                    print(#function, " document updated : \(user.name)")
                                }
                                
                            }catch let err as NSError{
                                print(#function, "Unable to convert the JSON doc into Swift Object : \(err)")
                            }
                            
                        }//ForEach
                        
                    })//addSnapshotListener
                
            }catch let err as NSError{
                print(#function, "Unable to get all employee from database : \(err)")
            }
        }
    
    func deleteFriend(loggedUser: String, friendToDelete: User) {
        print("Deleting friend from list information")
        
        do {
            let friendsCollection = self.db
                .collection(COLLECTION_USERS)
                .document(loggedUser)
                .collection(COLLECTION_FRIENDS)
            
            friendsCollection
                .whereField("name", isEqualTo: friendToDelete.name)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print(#function, "Error getting documents: \(error)")
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else {
                        print(#function, "No documents found")
                        return
                    }
                    
                    if documents.isEmpty {
                        print(#function, "Friend not found")
                        return
                    }
                    
                    let documentToDelete = documents[0]
                    documentToDelete.reference.delete { error in
                        if let error = error {
                            print(#function, "Unable to delete friend from the database: \(error)")
                        } else {
                            self.friendList.removeAll()
                            self.getMyFriends(loggedUser: loggedUser)
                            print("Friend deleted")
                        }
                    }
                }
        } catch let error as NSError {
            print(#function, "Unable to delete friend from the database: \(error)")
        }
    }

    
    func checkExistingEvent(event: Event, completion: @escaping (Bool, Error?) -> Void) {
        
        let eventsCollectionRef = db.collection("events")

        // Build the query to search for events with matching criteria
        let query = eventsCollectionRef
            .whereField("type", isEqualTo: event.type)
            .whereField("datetimeUtc", isEqualTo: event.datetimeUtc)
            .whereField("venue.name", isEqualTo: event.venue.name)
            .whereField("venue.postalCode", isEqualTo: event.venue.postalCode)

        // Execute the query
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error checking existing event: \(error)")
                completion(false, error)
                return
            }

            guard let querySnapshot = querySnapshot else {
                print("No existing events found")
                completion(false, nil)
                return
            }

            if !querySnapshot.isEmpty {
                // Event already exists
                print("Event already exists")
                completion(true, nil)
            } else {
                // Event does not exist
                print("Event does not exist")
                completion(false, nil)
            }
        }
    }

    func createEvent(eventToCreate:Event){
        
        let eventsCollectionRef = db.collection("events")
        let newEventRef = eventsCollectionRef.document()

        do {
            try newEventRef.setData(from: eventToCreate) { error in
                if let error = error {
                    print("Error creating event: \(error)")
                } else {
                    print("Event created successfully")
                }
            }
        } catch {
            print("Error encoding event: \(error)")
        }

        
        
    }
    
    func addEventToFavorites(loggedUser:String, event: Event, completion: @escaping (Bool, Error?) -> Void) throws {
        print(#function, "Inserting event to favorite list")
        
        do {
            try self.db.collection(COLLECTION_USERS)
                .document(loggedUser)
                .collection(COLLECTION_EVENTS)
                .addDocument(from: event) { error in
                    if let error = error {
                        print(#function, "Unable to add event to user: \(error)")
                        completion(false, error)
                    } else {
                        print(#function, "Event Added")
                        completion(true, nil)
                    }
                }
        } catch let err {
            print(#function, "Unable to add event to database: \(err)")
            completion(false, err)
        }
    }
    
    
    func checkExistingEventinFavorites(currentuser:String,event: Event, completion: @escaping (Bool, Error?) -> Void) {
        
        let eventsCollectionRef = db.collection(COLLECTION_USERS).document(currentuser).collection(COLLECTION_EVENTS)

        // Build the query to search for events with matching criteria
        let query = eventsCollectionRef
            .whereField("type", isEqualTo: event.type)
            .whereField("datetimeUtc", isEqualTo: event.datetimeUtc)
            .whereField("venue.name", isEqualTo: event.venue.name)
            .whereField("venue.postalCode", isEqualTo: event.venue.postalCode)

        // Execute the query
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error checking existing event: \(error)")
                completion(false, error)
                return
            }

            guard let querySnapshot = querySnapshot else {
                print("No existing events found")
                completion(false, nil)
                return
            }

            if !querySnapshot.isEmpty {
                // Event already exists
                print("Event already exists")
                completion(true, nil)
            } else {
                // Event does not exist
                print("Event does not exist")
                completion(false, nil)
            }
        }
    }

    
    
    func addUserToEventAtendeeList(userToAdd: String, event: Event, completion: @escaping (Bool, Error?) -> Void) throws {
        print(#function, "Inserting attendee to event")
        
        self.getSingleUser(email: userToAdd){user in
            
            if let user = user{
                
                let eventsCollectionRef = self.db.collection(self.COLLECTION_EVENTS)

                // Build the query to search for events with matching criteria
                let query = eventsCollectionRef
                    .whereField("type", isEqualTo: event.type)
                    .whereField("datetimeUtc", isEqualTo: event.datetimeUtc)
                    .whereField("venue.name", isEqualTo: event.venue.name)
                    .whereField("venue.postalCode", isEqualTo: event.venue.postalCode)
                
                query.getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error checking existing event: \(error)")
                        completion(false, error)
                        return
                    }

                    guard let querySnapshot = querySnapshot else {
                        print("No existing events found")
                        completion(false, nil)
                        return
                    }

                    if let eventDoc = querySnapshot.documents.first {
                        // Event already exists
                        print("Event already exists")
                        
                        let eventRef = eventsCollectionRef.document(eventDoc.documentID)
                        let attendeesCollectionRef = eventRef.collection(self.COLLECTION_ATTENDEES)

                        // Add the user to the attendees collection
                        let userDocument = attendeesCollectionRef.document()
                        do {
                            try userDocument.setData(from: user) { error in
                                if let error = error {
                                    print("Error adding attendee to event: \(error)")
                                    completion(false, error)
                                } else {
                                    print("Attendee added to event successfully")
                                    completion(true, nil)
                                }
                            }
                        } catch {
                            print("Error encoding user: \(error)")
                            completion(false, error)
                        }
                    } else {
                        // Event does not exist
                        print("Event does not exist")
                        completion(false, nil)
                    }
                }
                
                
                
            }else{
                print("User Not Found so it can't be added")
            }
            
            
            
        }
        
        
    }
    
    func getSingleUser(email: String, completion: @escaping (User?) -> Void) {
        
        print(#function,"GET SINGLE USER FUNCTION")
            let usersCollectionRef = db.collection(COLLECTION_USERS)
            
            usersCollectionRef.whereField("email", isEqualTo: email)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error getting user data: \(error)")
                        completion(nil)
                        return
                    }
                    
                    guard let document = querySnapshot?.documents.first else {
                        print("No user data found")
                        completion(nil)
                        return
                    }
                    
                    let data = document.data()
                    if let name = data["name"] as? String,
                       let email = data["email"] as? String{
                        let user = User(name: name, email: email)
                        completion(user)
                    } else {
                        completion(nil) // Invalid user data
                    }
            }
        }


    func getMyEvents(loggedUser:String){
    print(#function, "Trying to get all user's events.")
            do{
                
                self.db
                    .collection(COLLECTION_USERS)
                    .document(loggedUser)
                    .collection(COLLECTION_EVENTS)
                    .addSnapshotListener({ (querySnapshot, error) in
                        
                        guard let snapshot = querySnapshot else{
                            print(#function, "Unable to retrieve data from database : \(error)")
                            return
                        }
                        
                        snapshot.documentChanges.forEach{ (docChange) in
                            
                            do{
                                //convert JSON document to swift object
                                var event : Event = try docChange.document.data(as: Event.self)
                                
                                //get the document id so that it can be used for updating and deleting document
                                var documentID = docChange.document.documentID
//
//                                //set the document id to the converted object
                                //event.id = documentID
                                
                                //if new document added, perform required operations
                                if docChange.type == .added{
                                    self.favEventList.append(event)
                                    print(#function, "New document added : \(event.venue.name)")
                                }
                                
                                //if a document deleted, perform required operations
                                if docChange.type == .removed{
                                    print(#function, " document removed : \(event.venue.name)")
                                }
                                
                                //if a document updated, perform required operations
                                if docChange.type == .modified{
                                    
                                    print(#function, " document updated : \(event.venue.name)")
                                }
                                
                            }catch let err as NSError{
                                print(#function, "Unable to convert the JSON doc into Swift Object : \(err)")
                            }
                            
                        }//ForEach
                        
                    })//addSnapshotListener
                
            }catch let err as NSError{
                print(#function, "Unable to get all employee from database : \(err)")
            }
        }
    
    func deleteEventFromFavorites(loggedUser:String, eventToDelete: Event) {
        
        let eventCollectionRef = self.db.collection(COLLECTION_USERS)
            .document(loggedUser)
            .collection(COLLECTION_EVENTS)
        
        // Build the query to find the event based on criteria
        let query = eventCollectionRef
            .whereField("type", isEqualTo: eventToDelete.type)
            .whereField("datetimeUtc", isEqualTo: eventToDelete.datetimeUtc)
            .whereField("venue.name", isEqualTo: eventToDelete.venue.name)
        
        // Execute the query
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error deleting event: \(error)")
                return
            }
            
            guard let querySnapshot = querySnapshot else {
                print("No matching events found")
                return
            }
            
            // Delete the matching event documents
            for document in querySnapshot.documents {
                document.reference.delete { error in
                    if let error = error {
                        print("Error deleting event: \(error)")
                    } else {
                        print("Event deleted successfully")
                        self.favEventList.removeAll()
                        self.getMyEvents(loggedUser: loggedUser)
                    }
                }
            }
        }
    }
    
    func deleteAllFavoriteEvents(loggedUser:String){
        
        let collectionRef =  db.collection(COLLECTION_USERS).document(loggedUser).collection(COLLECTION_EVENTS)
        
        collectionRef.getDocuments { snapshot, error in
                guard let snapshot = snapshot else {
                    print("Error fetching documents in collection")
                    return
                }
                
                let batch = collectionRef.firestore.batch()
                
                for document in snapshot.documents {
                    let documentRef = collectionRef.document(document.documentID)
                    batch.deleteDocument(documentRef)
                }
                
                batch.commit { error in
                    if let error = error {
                        print("Error deleting documents in collection")
                    } else {
                        print("Documents in collection  deleted successfully")
                    }
                }
            }
        
    }
    
    func deleteAttendee(loggedUser: String, event:Event, completion: @escaping (Bool, Error?) -> Void) {
        let eventsCollectionRef = db.collection(COLLECTION_EVENTS)
        
        let query = eventsCollectionRef
            .whereField("type", isEqualTo: event.type)
            .whereField("datetimeUtc", isEqualTo: event.datetimeUtc)
            .whereField("venue.name", isEqualTo: event.venue.name)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error deleting attendee: \(error)")
                completion(false, error)
                return
            }
            
            guard let querySnapshot = querySnapshot else {
                print("No matching events found")
                completion(false, nil)
                return
            }
            
            for document in querySnapshot.documents {
                let attendeesCollectionRef = document.reference.collection(self.COLLECTION_ATTENDEES)
                
                attendeesCollectionRef.whereField("email", isEqualTo: loggedUser).getDocuments { (attendeesQuerySnapshot, attendeesError) in
                    if let attendeesError = attendeesError {
                        print("Error deleting attendee: \(attendeesError)")
                        completion(false, attendeesError)
                        return
                    }
                    
                    guard let attendeesQuerySnapshot = attendeesQuerySnapshot else {
                        print("No matching attendees found")
                        completion(false, nil)
                        return
                    }
                    
                    for attendeeDocument in attendeesQuerySnapshot.documents {
                        attendeeDocument.reference.delete { attendeeError in
                            if let attendeeError = attendeeError {
                                print("Error deleting attendee document: \(attendeeError)")
                                completion(false, attendeeError)
                            } else {
                                print("Attendee document deleted successfully")
                                completion(true, nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func deleteAttendeeFromMultipleEvents(loggedUser2:String){
        
        for event in self.favEventList{
            
            self.deleteAttendee(loggedUser: loggedUser2, event: event){success, error in
                
                if success {
                    print("Sucess! User was deleted from all events atendee list  ")
                }else{
                    
                    print("Error! User was NOT deleted from all events atendee list  ")
                }
                
            }
            
        }
        
    }
    
    func getUserEvents(userEmail:String){
    print(#function, "Trying to get all user's events.")
            do{
                
                self.db
                    .collection(COLLECTION_USERS)
                    .document(userEmail)
                    .collection(COLLECTION_EVENTS)
                    .addSnapshotListener({ (querySnapshot, error) in
                        
                        guard let snapshot = querySnapshot else{
                            print(#function, "Unable to retrieve data from database : \(error)")
                            return
                        }
                        
                        snapshot.documentChanges.forEach{ (docChange) in
                            
                            do{
                                //convert JSON document to swift object
                                var event : Event = try docChange.document.data(as: Event.self)
                                
                                //get the document id so that it can be used for updating and deleting document
                                //var documentID = docChange.document.documentID
//
//                                //set the document id to the converted object
                                //event.id = documentID
                                
                                //if new document added, perform required operations
                                if docChange.type == .added{
                                    self.userEventList.append(event)
                                    print(#function, "New document added : \(event.venue.name) to this date:\(event.datetimeUtc)")
                                }
                                
                                //if a document deleted, perform required operations
                                if docChange.type == .removed{
                                    print(#function, " document removed : \(event.venue.name)")
                                }
                                
                                //if a document updated, perform required operations
                                if docChange.type == .modified{
                                    
                                    print(#function, " document updated : \(event.venue.name)")
                                }
                                
                            }catch let err as NSError{
                                print(#function, "Unable to convert the JSON doc into Swift Object : \(err)")
                            }
                            
                        }//ForEach
                        
                    })//addSnapshotListener
                
                
            }catch let err as NSError{
                print(#function, "Unable to get all employee from database : \(err)")
            }
        }
    
    func getUserClosestEvent(userEmail: String, completion: @escaping (Event?) -> Void) {
        print(#function, "Trying to get all user's events.")
        do {
            self.db
                .collection(COLLECTION_USERS)
                .document(userEmail)
                .collection(COLLECTION_EVENTS)
                .getDocuments { (querySnapshot, error) in
                    guard let snapshot = querySnapshot else {
                        print(#function, "Unable to retrieve data from the database: \(error)")
                        completion(nil)
                        return
                    }

                    var closestEvent: Event?
                    var closestDateDifference: TimeInterval = .greatestFiniteMagnitude

                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

                    for document in snapshot.documents {
                        do {
                            var event: Event = try document.data(as: Event.self)
                            guard let eventDate = dateFormatter.date(from: event.datetimeUtc) else {
                                continue
                            }

                            let currentDate = Date()
                            let dateDifference = eventDate.timeIntervalSince(currentDate)

                            if dateDifference >= 0 && dateDifference < closestDateDifference {
                                closestDateDifference = dateDifference
                                closestEvent = event
                            }
                        } catch let err as NSError {
                            print(#function, "Unable to convert the JSON doc into a Swift object: \(err)")
                        }
                    }

                    completion(closestEvent)
                }
        } catch let err as NSError {
            print(#function, "Unable to get all events from the database: \(err)")
            completion(nil)
        }
    }
    
    func getFriendsWhoAreAttendingSameEvent(event:Event){
        
        for friend in friendList{
            
            self.checkSingleFriendEvents(friend: friend.email, eventToCheck: event){succes, error in
                
                if let error = error {
                        print("Error checking friend's events: \(error)")
                        return
                    }
                    
                    if succes {
                        
                        self.friendsAttendingSameEvent.append(friend)
                        
                    } else {
                        print("Friend does not have a matching event")
                    }
                
            }
            
            
            
        }
        
        
        
    }
    
    func checkSingleFriendEvents(friend: String, eventToCheck: Event, completion: @escaping (Bool, Error?) -> Void) {
        do {
            self.db
                .collection(COLLECTION_USERS)
                .document(friend)
                .collection(COLLECTION_EVENTS)
                .getDocuments { (querySnapshot, error) in
                    guard let snapshot = querySnapshot else {
                        print(#function, "Unable to retrieve data from the database: \(error)")
                        completion(false, error)
                        return
                    }
                    
                    for document in snapshot.documents {
                        do {
                            let event: Event = try document.data(as: Event.self)
                            
                            if event.venue.name == eventToCheck.venue.name {
                                completion(true, nil)
                                return
                            }
                        } catch let err as NSError {
                            print(#function, "Unable to convert the JSON doc into a Swift object: \(err)")
                        }
                    }
                    
                    completion(false, nil)
                }
        } catch let err as NSError {
            print(#function, "Unable to get all events from the database: \(err)")
            completion(false, err)
        }
    }

    

}

