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
            NavigationLink{
                Text(group.subject)
            }label: {
                HStack{
                    Image(systemName: "person.2")
                    Text(group.subject)
                }
            }
            
        }
    }
}

#Preview {
    GroupList(groups: [])
}
