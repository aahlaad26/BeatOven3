//
//  GroupList.swift
//  Socialmedia
//
//  Created by mathangy on 20/03/24.
//

import SwiftUI

struct GroupList: View {
    let groups: [Groupped]
    var body: some View {
        List(groups){ group in
            NavigationLink(destination: GroupDetailView(group: group),
                           label: {
                               HStack{
                                   Image(systemName: "person.2")
                                   Text(group.subject)
                                   
                               }
                           })
            .onTapGesture {
                print("NavigationLink was tapped.")
            }
        }
    }
}
