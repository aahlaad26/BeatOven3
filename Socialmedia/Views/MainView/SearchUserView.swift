//
//  SearchUserView.swift
//  Overall_Backend
//
//  Created by user4 on 03/03/24.
//
import SwiftUI
import Firebase
import FirebaseFirestore

struct SearchUserView: View {
    // View properties
    @State private var fetchedUsers: [User] = []
    @State private var searchedUsers: [User] = []
    @State private var searchText: String = ""
    @State private var posts: [Post] = []
    @Environment(\.dismiss) private var dismiss
    @State private var newPortfolios: [PortfolioData] = []
    let instruments = ["Guitar", "Percussion", "Bass", "Piano", "Ensemble", "Saxophone", "Flute", "Trumpet", "EDM", "Music Production"]
    let genres = ["Rock", "Pop", "Hip Hop", "Electronic", "Country", "Jazz", "Blues", "Classical", "Metal", "R&B"]
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(instruments, id: \.self) { instrument in
                            Button(action: {
                                searchUsers(for: instrument)
                            }) {
                                Text(instrument)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 10)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(genres, id: \.self) { genre in
                            Button(action: {
                                searchUsers(for: genre)
                            }) {
                                Text(genre)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 10)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                }
                
                List {
                                   ForEach(searchedUsers.isEmpty ? fetchedUsers : searchedUsers) { user in
                                       NavigationLink(destination: ReusableProfileContent(posts: $posts, user: user)) {
                                           Text(user.username)
                                               .font(.callout)
                                               .hAlign(.leading)
                                       }
                                   }
                                   .listRowBackground(Color.clear)
                               }
                               .listStyle(.plain)
                               .navigationBarTitleDisplayMode(.inline)
                               .navigationTitle("Discover")
                               .searchable(text: $searchText)
                               .onChange(of: searchText) { newValue in
                                   if newValue.isEmpty {
                                       searchedUsers = []
                                   } else {
                                       searchByUsername()
                                   }
                               }
                               .background(Color("bg-color"))
                               .scrollContentBackground(.hidden)
                 
                           }
                       }
                   }
    


                   
    func searchUsers(for tag: String) {
            Task {
                do {
                    var query: Query!
                    if instruments.contains(tag) {
                        query = Firestore.firestore().collection("Users").whereField("selectedInstruments", arrayContains: tag)
                    } else if genres.contains(tag) {
                        query = Firestore.firestore().collection("Users").whereField("selectedGenre", arrayContains: tag)
                    }
                    
                    let snapshot = try await query.getDocuments()
                    let users = snapshot.documents.compactMap { document in
                        try? document.data(as: User.self)
                    }
                    
                    fetchedUsers = users
                    
                    for user in users {
                        fetchPosts(for: user, with: tag)
                    }
                } catch {
                    print("Error searching users: \(error)")
                }
            }
        }
   


    func searchByUsername() {
        let query = Firestore.firestore().collection("Users")
            .whereField("username", isGreaterThanOrEqualTo: searchText)
            .whereField("username", isLessThanOrEqualTo: "\(searchText)\u{f8ff}")
        
        query.getDocuments { querySnapshot, error in
            if let error = error {
                print("Error searching users by username: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                return
            }
            
            let users = documents.compactMap { document -> User? in
                try? document.data(as: User.self)
            }
            
            DispatchQueue.main.async {
                self.searchedUsers = users
            }
        }
    }


    
    
    
    func fetchPosts(for user: User, with tag: String) {
        let postsRef = Firestore.firestore().collection("Posts")
        let query = postsRef.whereField("userId", isEqualTo: user.id)
                            .whereField("tags", arrayContains: tag)
                            .order(by: "timestamp", descending: true)
                            .limit(to: 10)

        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting posts: \(error)")
            } else {
                DispatchQueue.main.async {
                    self.posts = snapshot?.documents.compactMap { document in
                        try? document.data(as: Post.self)
                    } ?? []
                }
            }
        }
    }
}


struct SearchUserView_Previews: PreviewProvider {
    static var previews: some View {
        SearchUserView()
    }
}




//import SwiftUI
//import Firebase
//import FirebaseFirestore
//struct SearchUserView: View {
//    //view properties
//    @State private var fetchedUsers: [User] = []
//    @State private var searchText: String = ""
//    @State private var posts : [Post] = []
//    @Environment(\.dismiss) private var dismiss
//    var body: some View {
//        
//        NavigationStack{
//            List{
//                ForEach(fetchedUsers){
//                    user in
//                    NavigationLink{
//                        ReusableProfileContent(posts: $posts, user: user)
//                    }label: {
//                        Text(user.username)
//                            .font(.callout)
//                            .hAlign(.leading)
//                    }
//                    
//                }
//                .listRowBackground(Color.clear)
//            }
//            .listStyle(.plain)
//            .navigationBarTitleDisplayMode(.inline)
//                .navigationTitle("Search User")
//                .searchable(text: $searchText)
//                .onSubmit(of: .search, {
//                    Task{await searchUsers()}
//                })
//                .onChange(of: searchText, perform:{
//                    newValue in
//                    if newValue.isEmpty{
//                        fetchedUsers = []
//                        
//                    }
//                })
//                .background(Color("bg-color"))
//                .scrollContentBackground(.hidden)
//        }
//                
//        
//    }
//    func searchUsers()async{
//        do{
////            let querylowerCased = searchText.lowercased()
////            let queryupperCased = searchText.uppercased()
//            let documents = try await Firestore.firestore().collection("Users").whereField("username", isGreaterThanOrEqualTo:searchText)
//                .whereField("username", isLessThanOrEqualTo: "\(searchText)\u{f8ff}")
//                .getDocuments()
//            
//            let users = try documents.documents.compactMap{doc -> User? in
//                try doc.data(as: User.self)
//            }
//            //ui on mainthread
//            
//            await MainActor.run(body: {
//                fetchedUsers = users
//            })
//            
//        }catch{
//            print(error.localizedDescription)
//        }
//    }
//}
//
//#Preview {
//    SearchUserView()
//}
