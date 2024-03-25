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
        .navigationTitle("Audio Files")
        
        
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
    @State private var isDownloading = false
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
                .presentationDetents([.height(700)])
                }
        .alert(isPresented: $showAlert) {
                    Alert(title: Text("Downloaded"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
    }
    func downloadSong(){
        if let url = grpAudio.audioURL{
            let storageRef = Storage.storage().reference(forURL: url.absoluteString)
            let localURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let downloadTask = storageRef.write(toFile: localURL) { url, error in
              if let error = error {
                print("Error in download")
              } else {
                // Local file URL for "images/island.jpg" is returned
                  print("downloaded")
              }
            }
        }
        
        
        
    }
    func downloadAudioFile() {
        isDownloading = true
        guard let downloadURL = grpAudio.audioURL else {
                print("Invalid download URL")
                return
            }
            
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let destinationURL = documentsDirectory?.appendingPathComponent("\(grpAudio.title).mp3")
        if let destinationURL = destinationURL{
            if FileManager().fileExists(atPath: destinationURL.path){
                checkFileExists()
                print("File already exists")
                isDownloading = false
            }
            else{
                print("Downloading")
                let urlRequest = URLRequest(url: grpAudio.audioURL!)

                            let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                                if let error = error {
                                    print("Request error: ", error)
                                    self.isDownloading = false
                                    return
                                }

                                guard let response = response as? HTTPURLResponse else { return }

                                if response.statusCode == 200 {
                                    guard let data = data else {
                                        self.isDownloading = false
                                        return
                                    }
                                    DispatchQueue.main.async {
                                        do {
                                            try data.write(to: destinationURL, options: Data.WritingOptions.atomic)
                                            DispatchQueue.main.async {
                                                self.isDownloading = false
                                            }
                                        } catch let error {
                                            print("Error decoding: ", error)
                                            self.isDownloading = false
                                        }
                                    }
                                }
                            }
                            dataTask.resume()
                checkFileExists()
                        
            }
        }
        }
    func checkFileExists() {
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

        let destinationUrl = docsUrl?.appendingPathComponent("\(grpAudio.title).mp4")
        if let destinationUrl = destinationUrl {
            if (FileManager().fileExists(atPath: destinationUrl.path)) {
                isDownloading = true
                print("Does exist")
            } else {
                isDownloading = false
                print("Doesnt exist")
            }
        } else {
            isDownloading = false
            print("Doesnt exist")
        }
    }
}
