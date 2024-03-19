//
//  AddNewGroupView.swift
//  Socialmedia
//
//  Created by mathangy on 18/03/24.
//

import SwiftUI

struct AddNewGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var model: Model
    @State private var groupSubject: String = ""
    private var isFormValid: Bool{
        !groupSubject.isEmpty
    }
    private func saveGroup(){
        let group = Groupped(subject: groupSubject)
        model.saveGroup(group: group){ error in
            if let error{
                print(error.localizedDescription)
            }
        }
    }
    var body: some View {
        NavigationStack{
            VStack{
                HStack{
                    TextField("Group Subject", text: $groupSubject)
                }
                Spacer()
            }.toolbar{
                ToolbarItem(placement: .principal){
                    Text("New Group")
                        .bold()
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
            .environmentObject(Model())
    }
}
