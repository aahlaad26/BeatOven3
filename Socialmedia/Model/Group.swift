//
//  Group.swift
//  Socialmedia
//
//  Created by mathangy on 19/03/24.
//

import Foundation
struct Groupped: Codable, Identifiable{
    var documentId: String? = nil
    let subject: String
    
    var id: String{
        documentId ?? UUID().uuidString
    }
}

extension Groupped{
    func toDictionary() -> [String: Any]{
        return ["subject": subject]
    }
}
