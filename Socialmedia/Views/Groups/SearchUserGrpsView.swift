//
//  SearchUserGrpsView.swift
//  Socialmedia
//
//  Created by user2 on 19/03/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import SDWebImageSwiftUI
struct SearchUserGrpsView: View {
    @State private var fetchedUsers: [User] = []
    @State private var searchText: String = ""
    @State private var posts : [Post] = []
//    @Environment(\.dismiss) private var dismiss
    @ObservedObject var ID = UserIDs()
    var body: some View {
        
        NavigationStack{
            List{
                ForEach(fetchedUsers){
                    user in
                    Button(action: {ID.addUser(name: user.userid)
                        print(ID.userIDs[0])
                        
                    }){
                        HStack(spacing: 12){
                            WebImage(url: user.userprofileURL)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50 , height: 50)
                            .clipShape(Circle())
                            VStack(alignment: .leading, spacing: 6){
                                Text(user.username)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Text(user.userbio)
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                                    .lineLimit(3)
                                // MARK: Displaying Bio Link, If given while signin
                                if let bioLink = URL(string: user.userbiolink){
                                    Link(user.userbiolink, destination: bioLink)
                                        .font(.callout)
                                        .tint(.blue)
                                        .lineLimit(1)
                                }
                            }
                            .hAlign(.leading)
                        }
                    }
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Search User")
                .searchable(text: $searchText)
                .onSubmit(of: .search, {
                    Task{await searchUsers()}
                })
                .onChange(of: searchText, perform:{
                    newValue in
                    if newValue.isEmpty{
                        fetchedUsers = []
                        
                    }
                })
                .scrollContentBackground(.hidden)
        }
                
        
    }
    func searchUsers()async{
        do{
//            let querylowerCased = searchText.lowercased()
//            let queryupperCased = searchText.uppercased()
            let documents = try await Firestore.firestore().collection("Users").whereField("username", isGreaterThanOrEqualTo:searchText)
                .whereField("username", isLessThanOrEqualTo: "\(searchText)\u{f8ff}")
                .getDocuments()
            
            let users = try documents.documents.compactMap{doc -> User? in
                try doc.data(as: User.self)
            }
            //ui on mainthread
            
            await MainActor.run(body: {
                fetchedUsers = users
            })
            
        }catch{
            print(error.localizedDescription)
        }
    }
}

#Preview {
    SearchUserGrpsView()
}
