//
//  Group.swift
//  Socialmedia
//
//  Created by mathangy on 19/03/24.
//

import Foundation
import FirebaseFirestore
struct Groupped: Codable, Identifiable,Hashable{
    var documentId: String? = nil
    let subject: String
    var grpProfileImage: URL
    var id: String{
        documentId ?? UUID().uuidString
    }
    var userIDs:[String]
    var requests:[String]
}

extension Groupped{
    func toDictionary() -> [String: Any]{
        return ["subject": subject]
    }
    static func fromSnapShot(snapshot: QueryDocumentSnapshot) -> Groupped?{
        let dictionary = snapshot.data()
        guard let subject = dictionary["subject"] as? String else{
            return nil
        }
        guard let url = dictionary["grpProfileImage"] as? String else{
            return nil
        }
        guard let Url = URL(string: url) else{
            return nil
        }
        let userIDs = dictionary["userIDs"] as! [String]
        let requests = dictionary["requests"] as! [String]
        return Groupped(documentId: snapshot.documentID, subject: subject, grpProfileImage: Url , userIDs: userIDs,requests: requests)
    }
}
