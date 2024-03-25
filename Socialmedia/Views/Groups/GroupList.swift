//
//  GroupList.swift
//  Socialmedia
//
//  Created by mathangy on 20/03/24.
//


import SwiftUI
import SDWebImageSwiftUI

struct GroupList: View {
    let groups: [Groupped]
    @AppStorage("user_profile_url") var profileURL:URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    @AppStorage("log_status") var logStatus:Bool = false
    @State private var searchText = ""
    var body: some View {
        NavigationStack{
            ForEach(groups.filter { searchText.isEmpty ? true : $0.subject.contains(searchText)}){ group in
                NavigationLink(destination: GroupDetailView(group: group),
                               label: {
                    VStack{
                        HStack{
                           let url = group.grpProfileImage
                                WebImage(url: url)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                                    .padding(.horizontal)
                                    Text(group.subject)
                                               .font(.title3)
                                           Spacer()
                                           Image(systemName:"arrow.right")
                                           
                                       }
                                       .padding()
                                       .foregroundColor(.black)
                        Divider()
                    }
                               })
                
                .onTapGesture {
                    print("NavigationLink was tapped.")
                    

                }
            }
            
            .searchable(text: $searchText, prompt: "Search by name...")
        }
    }
}
