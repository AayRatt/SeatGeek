import Foundation
import FirebaseFirestoreSwift

struct User : Codable, Hashable{
    
    @DocumentID var id: String? = UUID().uuidString
    var name : String
    var email : String

    init(id: String? = nil, name:String, email:String) {
        self.id = id
        self.email = email
        self.name =  name
    }
    
    
    init?(dictionary : [String : Any]){

        guard let name = dictionary["name"] as? String else{
            print(#function, "Unable to get user name from JSON")
            return nil
        }

        guard let email = dictionary["email"] as? String else{
            print(#function, "Unable to get email name from JSON")
            return nil
        }
        

        self.init(name: name, email: email)


    }
    
    
}
