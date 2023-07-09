import Foundation
import FirebaseFirestore
import FirebaseAuth


class FirestoreController : ObservableObject{
    
    @Published var userList = [User]()
    @Published var friendList = [User]()
    
    
    //@Published var loggedUserInfo =  User(name: "", email: "", phone: "", carPlate: "")
    private let COLLECTION_USERS = "users"
    private let COLLECTION_FRIENDS = "friends"
    
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
    
      
    

}

