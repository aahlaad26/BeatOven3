//
//  ReusableProfileView.swift
//  Overall_Backend
//
//  Created by user4 on 03/03/24.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
struct ReusableProfileContent: View {
    @State var errorMessage = ""
    @AppStorage("user_profile_url") var profileURL:URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    @AppStorage("log_status") var logStatus:Bool = false
    @Binding var posts: [Post]
    //view properties
    @State private var portfolioData: PortfolioData?
    @State private var isLoading: Bool = true
    @State var isFetching: Bool = true
    //pagination
    @State private var paginationDoc: QueryDocumentSnapshot?
    @State private var showFetchPortfolioView = false
    @State var user:User
    @State private var tempUser: User?
    var body: some View {
        NavigationStack{
                
                ScrollView(.vertical, showsIndicators: false){
                    LazyVStack(alignment: .leading){
                        HStack(spacing:20){
                            WebImage(url: user.userprofileURL)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100 , height: 100)
                            .clipShape(Circle())
                            VStack{
                                
                                if let followers = user.followers{
                                    Text("\(followers.count)")
                                }
                                else{
                                    Text("0")
                                }
                                Text("Followers")
                            }
                            VStack{
                                
                                if let following = user.following{
                                    Text("\(following.count)")
                                }
                                else{
                                    Text("0")
                                }
                                Text("Following")
                            }
                            VStack{
                                Text("\(posts.count)")
                                Text("Posts")
                            }
                                
                                
                            
                            
                            
                            
                        }.padding(.bottom)
                        
                        VStack(alignment: .leading, spacing: 6){
                            Text(user.username)
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text(user.userbio)
                                .font(.title3)
                                .foregroundStyle(Color.gray)
                                .lineLimit(3)
                            // MARK: Displaying Bio Link, If given while signin
                            if let bioLink = URL(string: user.userbiolink){
                                Link(user.userbiolink, destination: bioLink)
                                    .font(.subheadline)
                                    .tint(.blue)
                                    .lineLimit(1)
                            }
                            if let selectedInstruments = user.selectedInstruments {
                                Text("Instruments: \(selectedInstruments.joined(separator: ", "))")
                                    .font(.subheadline)  // Set your desired size here
                                    .foregroundColor(.gray)
                                    .lineLimit(3)
                            }
                            if let selectedGenres = user.selectedGenre {
                                                                Text("Genres: \(selectedGenres.joined(separator: ", "))")
                                    .font(.subheadline)
                                                                    .foregroundColor(.gray)
                                                                    .lineLimit(1)
                                                            }
                            
                            
                        }
                        .hAlign(.leading)
                        HStack(spacing: 20){
                            if user.userid != userUID{
                                if let followers = user.followers{
                                    if followers.contains(userUID){
                                        Button(action:follow){
                                            Text("Unfollow")
                                                .font(.title2)
                                                .fontWeight(.semibold)
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(Color("button2-color"))
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                        }
                                    }
                                    else{
                                        Button(action:follow){
                                            Text("Follow")
                                                .font(.title2)
                                                .fontWeight(.semibold)
                                                .padding()
                                                .frame(maxWidth: .infinity, minHeight: 40)
                                                .background(Color("button2-color"))
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                        }
                                    }
                                }
                                else{
                                    Button(action:follow){
                                        Text("Follow")
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .padding()
                                            .background(Color("button2-color"))
                                            .frame(maxWidth: .infinity, minHeight: 40)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                }
                                Button(action: {
                                
                                  showFetchPortfolioView = true
                                }) {
                                    Image(systemName: "briefcase")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .padding()
                                    .background(Color("button2-color"))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                                .frame(width: 50, height: 50)
                            }
                            
                        }.padding(.vertical)
                        
                        // NavigationLink to FetchPortfolioView, conditionally shown based on the flag
                        NavigationLink(destination: FetchPortfolioView(user: user), isActive: $showFetchPortfolioView) {
                          EmptyView() // Placeholder, can be replaced with actual content
                        }
                        .offset(x: 150, y: -100) // Adjust offset for positioning if needed

                        
                        Divider()
                        Text("Posts").font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.black)
                            .hAlign(.leading)
                            .padding(.vertical,15)
                        
                            LazyVStack{// used in like onappear and keeps track of when the user is leaving the screen and entering
                                if isFetching{
                                    ProgressView()
                                        .padding(.top,30)
                                }else{
                                    if posts.isEmpty{
                                        //NO posts found
                                        Text("No posts found")
                                            .font(.caption)
                                            .foregroundStyle(Color.gray)
                                            .padding(.top,30)
                                        
                                    }else{
                                        //displaying posts
                                        Posts()
                                    }
                                }
                                
                            }
                            .padding(15)
                        
                        
                    }.padding(15)
                }.refreshable {
                    // scroll to refresh
                    isFetching = true
                    posts = []
                    await fetchPosts()
                    fetchUsersWithUID(uid: user.userid)
                    
                }
                .task{
                    // fetching for one time
                    guard posts.isEmpty else{return}
                    await fetchPosts()
                    fetchUsersWithUID(uid: user.userid)
                    
                }
                
            

        }
    }
    @ViewBuilder
    func Posts()-> some View{
        ForEach(posts){post in
//            Text(post.text)
            if(post.userUID == user.userid){
                PostCardView(post: post){updatedPost in
                    //updating post in the array
                    if let index = posts.firstIndex(where: {post in
                        post.id == updatedPost.id
                        
                    }){
                        posts[index].likedIDs = updatedPost.likedIDs
                    }
                } onDelete: {
                    // Removing Post from the array
                    withAnimation(.easeInOut(duration: 0.25)){
                        posts.removeAll{post.id == $0.id}
                        //id to be included
                    }
                    
                }
                .onAppear(){
                    //when last post appears, fetching the new post if it exists
                    if post.id == posts.last?.id && paginationDoc != nil{
                        Task{await fetchPosts()}
                    }
                }
                Divider()
                    .padding(.horizontal,-15)

            }
            
        }
    }
    // fetching posts
    
    func fetchPosts()async{
        do{
            var query: Query!
            //implementing pagination here
            if let paginationDoc{
                query = Firestore.firestore().collection("Posts")
                    .whereField("userUID",isEqualTo: user.userid)
                    .order(by: "publishedDate", descending: true)
                    .start(afterDocument:paginationDoc)
                    .limit(to: 20)
            }else{
                query = Firestore.firestore().collection("Posts")
                    .whereField("userUID",isEqualTo: user.userid)
                    .order(by: "publishedDate", descending: true)
                    .limit(to: 20)
            }
           
            let docs = try await query.getDocuments()
            let fetchedPosts = docs.documents.compactMap{doc->Post? in
                try? doc.data(as: Post.self)
            }
            await MainActor.run(body: {
                posts.append(contentsOf: fetchedPosts)
                paginationDoc = docs.documents.last
                isFetching = false
            })
        }catch{
            print(error.localizedDescription)
        }
    }
    func follow(){
        Task{
            if user.followers == nil || user.followers == []{
                try await Firestore.firestore().collection("Users").document(user.userid).updateData([
                    "followers": FieldValue.arrayUnion([userUID])
                ])
                try await
                Firestore.firestore().collection("Users").document(userUID).updateData([
                    "following": FieldValue.arrayUnion([user.userid])
                ])
                print("userid added")
            }
            guard let followers = user.followers else{
                return
            }
            if followers.contains(userUID) {
                try await Firestore.firestore().collection("Users").document(user.userid).updateData([
                    "followers": FieldValue.arrayRemove([userUID])
                ])
                try await Firestore.firestore().collection("Users").document(userUID).updateData([
                    "following": FieldValue.arrayRemove([user.userid])
                ])
                print("userid removed")
            } else {
                try await Firestore.firestore().collection("Users").document(user.userid).updateData([
                    "followers": FieldValue.arrayUnion([userUID])
                ])
                try await
                Firestore.firestore().collection("Users").document(userUID).updateData([
                    "following": FieldValue.arrayUnion([user.userid])
                ])
                print("userid added")
            }
            fetchUsersWithUID(uid: user.userid)
        }
    }
    func fetchUsersWithUID(uid : String){
        FirebaseManager.shared.firestore.collection("Users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user:", error)
                return
            }
            
            self.tempUser = try? snapshot?.data(as: User.self)
            user = tempUser!
        }
    }
}

