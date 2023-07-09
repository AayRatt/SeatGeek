//
//  FirebaseAuthController.swift
//  ParkingApp
//
//  Created by Aayush Rattan on 2023-06-23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class FirebaseAuthController:ObservableObject {
    
    private let COLLECTION_USERS = "users"
    
    func signUp(name:String,email: String, password : String){
        
        Auth.auth().createUser(withEmail : email, password: password){ authResult, error in
            
            guard let result = authResult else{
                print(#function, "Error while signing up user : \(String(describing: error))")
                return
            }//guard let
            
            let db = Firestore.firestore()
            
            let userRef = db.collection("users").document(result.user.email ?? "")
            
            let userData: [String: Any] = [
                
                "name": name,
                "email": email,
            ]
            
            
            userRef.setData(userData) {
                error in
                if let error = error {
                    print(#function, "Error saving user data: \(error)")
                } else {
                    
                    print(#function, "User data saved successfully")
                    
                    // Add events
                    let eventsRef = db.collection("users").document(result.user.email ?? "").collection("events").document()
                    //add friendslist
                    
                    let friendsRef = db.collection("users").document(result.user.email ?? "").collection("friends").document()
                    
                    let eventsData: [String: Any] = [
                        "name": "Music Fest",
                        "date": "today"
                    ]
                    
                    let friendsData: [String: Any] = [
                        "name": "Mark",
                        "email": "m@m.com"
                    ]
                    
                    eventsRef.setData(eventsData) { error in
                        if let error = error {
                            print(#function, "Error saving events data: \(error)")
                        } else {
                            print(#function, "Events data saved successfully")
                        }
                    }
                    
                    friendsRef.setData(friendsData) { error in
                        if let error = error {
                            print(#function, "Error saving events data: \(error)")
                        } else {
                            print(#function, "Events data saved successfully")
                        }
                    }
                    
                    
                    print(#function, "AuthResult : \(result)")
                    
                    switch(authResult){
                    case .none:
                        print(#function, "Unable to create account")
                    case .some(_):
                        print(#function, "Successfully created user account")
                    }
                    
                }//auth
                
            }//function
        }
    }

            
    func signIn(email: String, password: String, completion: @escaping (Bool,String?) -> Void) {
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                if let error = error {
                    // Handle authentication error
                    print("Authentication failed: \(error.localizedDescription)")
                    completion(false, nil) // Pass false to the completion handler indicating authentication failure
                } else {
                    // Authentication successful
                    print("User authenticated successfully.")
                    
                    let userEmail = result?.user.email
                    
                    // Perform any additional actions after successful authentication
                    
                    completion(true, userEmail) // Pass true to the completion handler indicating authentication success
                }
            }
        }
            
            
    func signOut() {
                do {
                    try Auth.auth().signOut()
                    // Successful sign-out
                    print("User signed out successfully.")
                    
                    // Perform any additional actions after sign-out
                } catch let error {
                    // Error occurred during sign-out
                    print("Error signing out: \(error.localizedDescription)")
                }
            }

        

}
