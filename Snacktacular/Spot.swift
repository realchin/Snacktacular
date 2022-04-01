//
//  Spot.swift
//  Snacktacular
//
//  Created by Timothy Chin on 3/31/22.
//

import Foundation
import Firebase

class Spot {
    
    var name: String
    var address: String
    var averageRating: Double
    var numberOfReviews: Int
    var postingUserID: String
    var documentID: String
    
    var dictionary: [String: Any] {
        return["name": name, "address": address, "averageRating": averageRating, "numberOfReviews": numberOfReviews, "postingUserID": postingUserID]
    }
    
    init(name: String, address: String, averageRating: Double, numberOfReviews: Int, postingUserID: String, documentID: String) {
        self.name = name
        self.address = address
        self.averageRating = averageRating
        self.numberOfReviews = numberOfReviews
        self.postingUserID = postingUserID
        self.documentID = documentID
    }
    
    convenience init() {
        self.init(name: "", address: "", averageRating: 0.0, numberOfReviews: 0, postingUserID: "", documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let name = dictionary["name"] as! String? ?? ""
        let address = dictionary["address"] as! String? ?? ""
        let averageRating = dictionary["averageRating"] as! Double? ?? 0.0
        let numberOfReviews = dictionary["numberOfReviews"] as! Int? ?? 0
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
//        let documentID = dictionary["documentID"] as! String? ?? ""
        self.init(name: name, address: address, averageRating: averageRating, numberOfReviews: numberOfReviews, postingUserID: postingUserID, documentID: "")
    }
    
    func saveData(completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        // grab the user ID
        guard let postingUserID = Auth.auth().currentUser?.uid else {
            print("Error bc we don't have a valid postingUserID")
            return completion(false)
        }
        self.postingUserID = postingUserID
        // create dict representing data we want to save
        let dataToSave: [String: Any] = self.dictionary
        // if we have saved a record, we will have an ID, otherwise .addDocu will create one
        if self.documentID == "" {
            var ref: DocumentReference? = nil // Firestore will
            ref = db.collection("spots").addDocument(data: dataToSave){ (error) in
                guard error == nil else {
                    print("ERROR: adding docu")
                    return completion(false)
                }
                self.documentID = ref!.documentID
                print("Added docu: \(self.documentID)") // it works!
                completion(true)
            }
        } else { // else save to the existing documentID w/ .setData
            let ref = db.collection("spots").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                guard error == nil else {
                    print("ERROR: updating docu")
                    return completion(false)
                }
                print("Updated docu: \(self.documentID)") // it works!
                completion(true)
            }
        }
    }
}
