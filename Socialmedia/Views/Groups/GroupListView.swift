//
//  GroupListView.swift
//  Socialmedia
//
//  Created by mathangy on 18/03/24.
//

import SwiftUI

struct GroupListView: View {
    @State private var isPresented:Bool = false
    var body: some View {
        VStack{
            HStack{
                Spacer()
                Button("New Group"){
                    isPresented = true
                }
            }
            Spacer()
        }.padding()
            .sheet(isPresented: $isPresented){
                AddNewGroupView()
            }
    }
}

#Preview {
    GroupListView()
}
