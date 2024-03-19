//
//  AddNewGroupView.swift
//  Socialmedia
//
//  Created by mathangy on 18/03/24.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore


class UserIDs:ObservableObject{
    @Published var userIDs = [String]()
    func addUser(name: String) {
        userIDs.append(name)
    }
    func removeUser(name: String) {
        if let index = userIDs.firstIndex(of: name) {
            userIDs.remove(at: index)
        }
    }
}
struct AddNewGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var model: Model
    @State private var groupSubject: String = ""
    
     
      private var isFormValid: Bool { !groupSubject.isEmpty }
    func populateGroups() async throws{
        let db = Firestore.firestore()
        let snapshot = try await db.collection("groups").getDocuments()
        groups = snapshot.documents.compactMap{ snapshot in
            Groupped.fromSnapShot(snapshot:snapshot)
        }
    }
      func saveGroup() {
          print(ID.userIDs)
        let db = Firestore.firestore()
        let group = Groupped(subject: groupSubject)

        db.collection("groups").addDocument(data: group.toDictionary()) { error in
          if let error {
            print(error.localizedDescription)
          } else {
            dismiss()
          }
        }
        
      }
    
   
    @ObservedObject var ID = UserIDs()
    
    
    var body: some View {
        NavigationStack{
            VStack{
                
                Spacer()
                SearchUserGrpsView(ID: ID)
            }.toolbar{
                ToolbarItem(placement: .principal){
                    HStack{
                        TextField("Group Subject", text: $groupSubject)
                            .frame(width: 150)
                            .padding()
                    }

                    
                }
                ToolbarItem(placement: .navigationBarLeading){
                    Button("Cancel"){
                        dismiss()
                    }
                    
                }
                ToolbarItem(placement: .navigationBarTrailing){
                    Button("Create"){
                        saveGroup()
                    }.disabled(!isFormValid)
                    
                }
            }
            
        }.padding()
        
    }
}


//#Preview {
//    NavigationStack {
//        AddNewGroupView()
//            .environmentObject(model)
//    }
//}


