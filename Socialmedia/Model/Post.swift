//
//  Post.swift
//  Socialmedia
//
//  Created by user4 on 28/02/24.
//

import SwiftUI
import FirebaseFirestoreSwift
// MARK: Post Model



struct Post: Identifiable, Codable, Equatable, Hashable {
    @DocumentID var id: String?
    var text: String
    var imageURL: URL?
    var imageReferenceID: String = ""
    var songURL: URL?
    var songReferenceID: String = ""  
    var publishedDate: Date?
    var likedIDs: [String] = []
    var username: String
    var userUID: String
    var userProfileURL: URL
    var userInstruments: [String]?
    var userGenre: [String]?
    enum CodingKeys: CodingKey {
        case id
        case text
        case imageURL
        case imageReferenceID
        case songURL
        case songReferenceID
        case publishedDate
        case likedIDs
        case username
        case userUID
        case userProfileURL
        case userInstruments
        case userGenre
    }
}
