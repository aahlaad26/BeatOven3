//
//  RecentMessage.swift
//  LBTASwiftUIFirebaseChat
//
//  Created by Brian Voong on 11/21/21.
//

import Foundation
import FirebaseFirestoreSwift

struct RecentMessage: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    let text, email: String
    let fromId, toId: String
    let profileImageUrl: String
    let timestamp: Date
    
    var username: String
    
    // `timeAgo` doesn't need to be encoded/decoded as it's computed from `timestamp`.
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    // Specify only the properties you want to encode/decode.
    }
