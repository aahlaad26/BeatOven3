//
//  Model.swift
//  Socialmedia
//
//  Created by mathangy on 19/03/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class Model: ObservableObject{
    @Published var groups: [Groupped] = []
    func populateGroups() async throws {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("groups").getDocuments()
        groups = snapshot.documents.compactMap{ snapshot in
            Groupped.fromSnapShot(snapshot: snapshot)
        }
        
    }
    func saveGroup(group: Groupped , completion : @escaping (Error?) -> Void){
        let db = Firestore.firestore()
        var docRef : DocumentReference? = nil
        docRef = db.collection("groups").addDocument(data: group.toDictionary()) { [weak self] error in
           
            if error != nil{
                completion(error)
            }else{
                if let docRef{
                    var newGroup = group
                    newGroup.documentId = docRef.documentID
                    self?.groups.append(newGroup)
                    completion(nil)
                }else{
                    completion(nil)
                }
            }
        }
    }
}
