//
//  GroupDetailView.swift
//  Socialmedia
//
//  Created by mathangy on 20/03/24.

//
import SwiftUI
import Firebase
import FirebaseStorage
import SDWebImageSwiftUI
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
    @State private var alertMessage = ""
    @State private var showAlert = false
    var body: some View {
        VStack{
        
            HStack{
                Button(action:{isPresented = true}){
                    HStack{
                        WebImage(url: grpAudio.userProfileURL)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
    //                    ZStack{
    //                        Circle().frame(width: 50,height: 50,alignment: .center).foregroundColor(Color("button-color"))
    //                        Circle().frame(width: 20,height: 20,alignment: .center).foregroundColor(Color.white)
    //
    //                    }
                        Text(grpAudio.title)
                        
                        
                    }
                }
                Spacer()
                Menu{
                    //MARK: Two actions
                    //Logout, delete account
                    
                    Button("Download",action:downloadSong)
                    Button("Delete",role: .destructive,action: {})
                }label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.init(degrees: 90))
                        .tint(.black)
                        .scaleEffect(0.8)
                }
            }
        }
        .sheet(isPresented: $isPresented) {
                    // ProPlayer view presentation
                    ProPlayer(grpAudios: posts, grpAudio: grpAudio)
                .presentationDetents([.height(200)])
                }
        .alert(isPresented: $showAlert) {
                    Alert(title: Text("Downloaded"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
    }
    func downloadSong(){
        if let url = grpAudio.audioURL{
            let storageRef = Storage.storage().reference(forURL: url.absoluteString)
            let localURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(url.lastPathComponent)
            let downloadTask = storageRef.write(toFile: localURL) { url, error in
              if let error = error {
                // Uh-oh, an error occurred!
              } else {
                // Local file URL for "images/island.jpg" is returned
              }
            }
        }
        
        
        
    }
    func downloadAudioFile() {
        guard let downloadURL = grpAudio.audioURL else {
                print("Invalid download URL")
                return
            }
            
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationURL = documentsDirectory.appendingPathComponent(downloadURL.lastPathComponent)
            
            let session = URLSession.shared
            let downloadTask = session.downloadTask(with: downloadURL) { (tempURL, response, error) in
                if let error = error {
                    print("Error downloading file: \(error.localizedDescription)")
                    return
                }
                
                guard let tempURL = tempURL else {
                    print("Invalid temporary URL")
                    return
                }
                
                do {
                    try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                    let downloadLocation = destinationURL.path
                    print("File downloaded successfully at: \(downloadLocation)")
                    
                    // Show alert with download location
                    alertMessage = "File downloaded successfully at: \(downloadLocation)"
                    showAlert = true
                } catch {
                    print("Error saving file: \(error.localizedDescription)")
                }
            }
            
            downloadTask.resume()
        }
}
