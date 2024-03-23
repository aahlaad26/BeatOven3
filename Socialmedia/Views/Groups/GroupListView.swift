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
            ScrollView{
                VStack{
                    
                    GroupList(groups: model.groups)
                    
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
            .navigationTitle("Groups")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                Button("New Group"){
                    isPresented = true
                }
                }
            .background(Color("bg-color"))
            }
        }
    }


#Preview {
    GroupListView().environmentObject(Model())
}
