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
    @Binding var posts: [Post]
    //view properties
    @AppStorage("user_UID") private var userUID: String = ""
    @State private var portfolioData: PortfolioData?
    @State private var isLoading: Bool = true
    @State var isFetching: Bool = true
    //pagination
    @State private var paginationDoc: QueryDocumentSnapshot?
    @State private var showFetchPortfolioView: Bool = false
    var user:User
    var body: some View {
        NavigationStack{
            ZStack{
                
                ScrollView(.vertical, showsIndicators: false){
                    LazyVStack{
                        HStack(spacing: 12){
                            WebImage(url: user.userprofileURL)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100 , height: 100)
                            .clipShape(Circle())
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
                                        .font(.callout)
                                        .tint(.blue)
                                        .lineLimit(1)
                                }
                                if let selectedInstruments = user.selectedInstruments {
                                    Text("Instruments: \(selectedInstruments.joined(separator: ", "))")
                                        .font(.system(size: 14))  // Set your desired size here
                                        .foregroundColor(.gray)
                                        .lineLimit(3)
                                }
                                if let selectedGenres = user.selectedGenre {
                                    Text("Genres: \(selectedGenres.joined(separator: ", "))")
                                        .font(.system(size: 14))  // Set your desired size here
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                }

                            }
                            .hAlign(.leading)
                        }.padding(.bottom)
                       
                        Button(action: {
                        
                          showFetchPortfolioView = true
                        }) {
                            Image(systemName: "briefcase")
//                            .font(.title2)
//                            .fontWeight(.semibold)
//                            .padding()
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
                        }
                        .padding(.bottom)
                        .frame(width: 50, height: 50)
                        // NavigationLink to FetchPortfolioView, conditionally shown based on the flag
                        NavigationLink(destination: FetchPortfolioView(), isActive: $showFetchPortfolioView) {
                          EmptyView() // Placeholder, can be replaced with actual content
                        }
                        .offset(x: 150, y: -100) // Adjust offset for positioning if needed

                        
                        
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
                }
                .task{
                    // fetching for one time
                    guard posts.isEmpty else{return}
                    await fetchPosts()
                    
                }
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
                    .order(by: "publishedDate", descending: true)
                    .start(afterDocument:paginationDoc)
                    .limit(to: 20)
            }else{
                query = Firestore.firestore().collection("Posts")
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
    func fetchPortfolioData() {
        let db = Firestore.firestore()
        let documentReference = db.collection("portfolioData").document(userUID)

        documentReference.getDocument { (document, error) in
            if let document = document, document.exists {
                do {
                    self.portfolioData = try Firestore.Decoder().decode(PortfolioData.self, from: document.data()!)
                } catch let error {
                    print("Error decoding PortfolioData: \(error)")
                }
            } else {
                print("Document does not exist")
            }
            isLoading = false
        }
    }
}

