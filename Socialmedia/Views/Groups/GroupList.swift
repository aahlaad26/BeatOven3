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
    var body: some View {
        NavigationStack{
            ForEach(groups,id:\.self){ group in
                NavigationLink(destination: GroupDetailView(group: group),
                               label: {
                    HStack{
                        if let url = group.grpProfileImage{
                            WebImage(url: url)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                        }
                        Button(action:{print(group.grpProfileImage)}){
                            Text("UserIDs")
                        }
                                    Text(group.subject)
                                           .font(.title2)
                                       Spacer()
                                       Image(systemName:"arrow.right")
                                       
                                   }
                                   .foregroundColor(.black)
                               })
                
                .onTapGesture {
                    print("NavigationLink was tapped.")
                    

                }
            }.background(Color("bg-color"))
        }
    }
}
