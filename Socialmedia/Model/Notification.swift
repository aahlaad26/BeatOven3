//
//  Notification.swift
//  Socialmedia
//
//  Created by user2 on 06/04/24.
//

import Foundation
import FirebaseFirestoreSwift

struct Notification: Codable, Identifiable,Hashable{
    @DocumentID var documentId: String?
    var notiType : String
    var toUserID : String
    var fromUserID : String
    var fromUserProfileImage: URL?
    var fromUsername: String
    var dismissStatus: Bool
    var groupID : String
    var groupName: String
    var id: String{
        documentId ?? UUID().uuidString
    }
}
