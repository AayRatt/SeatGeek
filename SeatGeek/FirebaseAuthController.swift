//
//  FirebaseAuthController.swift
//  ParkingApp
//
//  Created by Aayush Rattan on 2023-06-23.
//

import Foundation
import FirebaseAuth

class FirebaseAuthController:ObservableObject {
    
    func signUp(email: String, password : String){
        Auth.auth().createUser(withEmail : email, password: password){ authResult, error in
            
            guard let result = authResult else{
                print(#function, "Error while signing up user : \(String(describing: error))")
                return
            }
            
            print(#function, "AuthResult : \(result)")
            
            switch(authResult){
            case .none:
                print(#function, "Unable to create account")
            case .some(_):
                print(#function, "Successfully created user account")
            }
            
        }
        
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                // Handle authentication error
                print("Authentication failed: \(error.localizedDescription)")
                completion(false) // Pass false to the completion handler indicating authentication failure
            } else {
                // Authentication successful
                print("User authenticated successfully.")
                
                // Perform any additional actions after successful authentication
                
                completion(true) // Pass true to the completion handler indicating authentication success
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
