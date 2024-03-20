//
//  GroupListView.swift
//  Socialmedia
//
//  Created by mathangy on 18/03/24.
//

import SwiftUI

struct GroupListView: View {
    @State private var isPresented:Bool = false
    @EnvironmentObject private var model: Model
    var body: some View {
        NavigationStack {
            VStack{
                HStack{
                    Spacer()
                    Button("New Group"){
                        isPresented = true
                    }
                }
                GroupList(groups: model.groups)
                Spacer()
            }
            .task{
                do{
                    try await model.populateGroups()
                }catch{
                    print(error)
                }
            }.padding()
                .sheet(isPresented: $isPresented){
                    AddNewGroupView()  
            }
        }
    }
}

#Preview {
    GroupListView().environmentObject(Model())
}
