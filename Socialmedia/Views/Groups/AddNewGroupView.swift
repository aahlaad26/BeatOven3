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
}
struct AddNewGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var groupSubject: String = ""
    private var isFormValid: Bool{
        !groupSubject.isEmpty
    }
    @ObservedObject var ID = UserIDs()
    private func saveGroup(){
        let group = Groupped(subject: groupSubject)
    }
    var body: some View {
        NavigationStack{
            VStack{
                
                Spacer()
                SearchUserGrpsView()
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


#Preview {
    NavigationStack {
        AddNewGroupView()
    }
}
