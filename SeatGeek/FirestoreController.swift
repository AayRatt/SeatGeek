import Foundation
import FirebaseFirestore
import FirebaseAuth


class FirestoreController : ObservableObject{
    
    @Published var userList = [User]()
    @Published var friendList = [User]()
    @Published var favEventList = [Event]()
    
    
    //@Published var loggedUserInfo =  User(name: "", email: "", phone: "", carPlate: "")
    private let COLLECTION_USERS = "users"
    private let COLLECTION_FRIENDS = "friends"
    private let COLLECTION_EVENTS = "events"
    
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
    
    
    func getAllUsers(){
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
                                var documentID = docChange.document.documentID
                                
                                //set the document id to the converted object
                                user.id = documentID
                                
                                //if new document added, perform required operations
                                if docChange.type == .added{
                                    self.userList.append(user)
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
                                var documentID = docChange.document.documentID
                                
                                //set the document id to the converted object
                                user.id = documentID
                                
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
    
    func deleteFriend(loggedUser:String, friendToDelete:User){
        
        print("Deleting friend from list information")
        

        do{
            try self.db
                .collection(COLLECTION_USERS)
                .document(loggedUser)
                .collection(COLLECTION_FRIENDS)
                .document(friendToDelete.id ?? "")
                .delete{ error in
                    if let err = error {
                        print(#function, "Unable to delete friend from database : \(err)")
                    }else{
                        print("Friend delete")
                    }
            }
        }catch let err as NSError{
            print(#function, "Unable to delete friend from database : \(err)")
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
//                                var documentID = docChange.document.documentID
//
//                                //set the document id to the converted object
//                                event.id = documentID
                                
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

}

