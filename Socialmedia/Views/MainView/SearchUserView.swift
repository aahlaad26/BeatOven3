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
    
    let instruments = ["Guitar", "Percussion", "Bass", "Piano", "Ensemble", "Saxophone", "Flute", "Trumpet", "EDM", "Music Production"]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(searchedUsers) { user in
                    NavigationLink(destination: ReusableProfileContent(posts: $posts, user: user)) {
                        Text(user.username)
                            .font(.callout)
                            .hAlign(.leading)
                    }
                }
                .listRowBackground(Color.clear)
                
                ForEach(instruments, id: \.self) { instrument in
                    Section(header: Text("Find \(instrument) Artists ")) {
                        ForEach(fetchedUsers.filter { $0.selectedInstruments?.contains(instrument) ?? false }) { user in
                            NavigationLink(destination: ReusableProfileContent(posts: $posts, user: user)) {
                                Text(user.username)
                                    .font(.callout)
                                    .hAlign(.leading)
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Search User")
            .searchable(text: $searchText)
            .onChange(of: searchText) { newValue in
                if newValue.isEmpty {
                    searchedUsers = []
                } else {
                    searchedUsers = fetchedUsers.filter { $0.username.localizedCaseInsensitiveContains(newValue) }
                }
            }
            .onAppear {
                Task {
                    await searchUsers()
                }
            }
            .background(Color("bg-color"))
            .scrollContentBackground(.hidden)
        }
    }
    
    func searchUsers() async {
        do {
            let querySnapshot = try await Firestore.firestore().collection("Users").getDocuments()
            let users = try querySnapshot.documents.compactMap { document -> User? in
                try document.data(as: User.self)
            }
            await MainActor.run {
                fetchedUsers = users
            }
        } catch {
            print("Error fetching users: \(error.localizedDescription)")
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
