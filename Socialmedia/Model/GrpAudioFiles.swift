//
//  GrpAudioFiles.swift
//  Socialmedia
//
//  Created by mathangy on 21/03/24.
//

import Foundation
import FirebaseFirestoreSwift
import SwiftUI

struct GrpAudioFiles: Identifiable,Hashable,Codable{
    @DocumentID var id: String?
    var title: String
    var audioURL: URL?
    
    var audioReferenceID: String = ""
    var publishedDate: Date?
    var username: String
    var userUID: String
    var userProfileURL: URL
    var groupID: String 
    
    enum CodingKeys: CodingKey {
        case id
        case title
        case audioURL
        case audioReferenceID
        case publishedDate
        case username
        case userUID
        case userProfileURL
        case groupID
    }
}






    
