//
//  GroupDetailView.swift
//  Socialmedia
//
//  Created by mathangy on 20/03/24.

//
import SwiftUI
import Firebase
struct GroupDetailView: View {
    @State var isFetching: Bool = true
    @State private var posts: [GrpAudioFiles] = []
    @State private var recentPosts: [GrpAudioFiles] = []
    @State private var paginationDoc: QueryDocumentSnapshot?
    let group: Groupped
    @State private var createNewAudio: Bool = false
    var body: some View {
        NavigationStack{
            ScrollView(.vertical, showsIndicators: false){
                Text("Details for \(group.subject)")
                LazyVStack{
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
                            
                            ForEach(posts,id:\.id){audio in
                                SongCell(posts: posts, grpAudio: audio)
                            }
                        }
                    }
                    
                }
                .padding(15)
                
            } .refreshable {
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
            
        }.overlay(alignment: .bottomTrailing){
            Button{
                createNewAudio.toggle()
            }label: {
                Image(systemName: "plus")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.white)
                    .padding(13)
                    .background( Color("button-color"),in:Circle())
            }
            .padding(15)
        }
        .navigationTitle("Posts")
        .navigationBarColor(Color("bg-color"))
        .background(Color("bg-color"))
        
    .fullScreenCover(isPresented: $createNewAudio){
        CreateAudioFileView(group: group){audio in
            // adding created posts at the top of the recent posts
            recentPosts.insert(audio, at: 0)
        }
    }
        
    }
    func fetchPosts()async{
        do{
            var query: Query!
            //implementing pagination here
            if let paginationDoc{
                query = Firestore.firestore().collection("Group_Audios")
                    .whereField("groupID",isEqualTo: group.id)
                    .order(by: "publishedDate", descending: true)
                    .start(afterDocument:paginationDoc)
                    .limit(to: 20)
            }else{
                query = Firestore.firestore().collection("Group_Audios")
                    .whereField("groupID",isEqualTo: group.id)
                    .order(by: "publishedDate", descending: true)
                    .limit(to: 20)
            }
           
            let docs = try await query.getDocuments()
            let fetchedPosts = docs.documents.compactMap{doc->GrpAudioFiles? in
                try? doc.data(as: GrpAudioFiles.self)
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
 
}
struct SongCell:View {
    @State private var isPresented = false
    var posts:[GrpAudioFiles]
    var grpAudio:GrpAudioFiles
    var body: some View {
        VStack{
            Button(action:{isPresented = true}){
                HStack{
                    ZStack{
                        Circle().frame(width: 50,height: 50,alignment: .center).foregroundColor(Color("button-color"))
                        Circle().frame(width: 20,height: 20,alignment: .center).foregroundColor(Color.white)
                        
                    }
                    Text(grpAudio.title)
                    
                }
            }
        }
        .sheet(isPresented: $isPresented){
            ProPlayer(grpAudios: posts, grpAudio: grpAudio)
        }
    }
}
