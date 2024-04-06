
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
    @State private var isActiveMembers = false
    @AppStorage("user_profile_url") private var profileURL: URL?
    @AppStorage("user_name") private var userName:String = ""
    @AppStorage("user_UID") private var userUID:String = ""
    @State private var fetchedUsers: [User] = []
    let group: Groupped
    @State private var createNewAudio: Bool = false
    var body: some View {
        NavigationStack{
            ScrollView(.vertical, showsIndicators: false){
                NavigationLink(destination: GroupMemberList(members: fetchedUsers), isActive: $isActiveMembers){
                    EmptyView()
                }
                LazyVStack{
                    if isFetching{
                        ProgressView()
                            .padding(.top,30)
                    }else{
                        if posts.isEmpty{
                            //NO posts found
                            Text("Workspace is Empty")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                                .padding(.top,30)
                            
                        }else{
                            //displaying posts
                            
                            ForEach(posts,id:\.id){audio in
                                SongCell(posts: posts, grpAudio: audio, refetch: fetchPosts)
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
                await fetchUsers()
            }
            .task{
                // fetching for one time
                guard posts.isEmpty else{return}
                await fetchPosts()
                await fetchUsers()
                
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
        .navigationTitle("\(group.subject)")
        .toolbar{
            ToolbarItem(placement: .topBarTrailing){
                Button(action:{isActiveMembers = true}){
                    Image(systemName: "person.fill")
                        .font(.caption)
                        
                        .foregroundStyle(Color.black)
                        .padding(8)
                        .contentShape(Rectangle())
                }
            }
        }
        
        
    .fullScreenCover(isPresented: $createNewAudio){
        CreateAudioFileView(group: group,refetch: fetchPosts){audio in
            // adding created posts at the top of the recent posts
            recentPosts.insert(audio, at: 0)
        }
    }
        
    }
    func fetchPosts()async{
        do{
            var query: Query!
            //implementing pagination here
//            if let paginationDoc{
////                query = Firestore.firestore().collection("Group_Audios")
////                    .whereField("groupID",isEqualTo: group.id)
////                    .order(by: "publishedDate", descending: false)
////                    .start(afterDocument:paginationDoc)
////                    .limit(to: 20)
//            }else{
                query = Firestore.firestore().collection("Group_Audios")
                    .whereField("groupID",isEqualTo: group.id)
                    .order(by: "publishedDate", descending: false)
                    .limit(to: 20)
//            }
           
            let docs = try await query.getDocuments()
            let fetchedPosts = docs.documents.compactMap{doc->GrpAudioFiles? in
                try? doc.data(as: GrpAudioFiles.self)
            }
            await MainActor.run(body: {
                posts = []
                posts.append(contentsOf: fetchedPosts)
//                posts = fetchedPosts
//                posts.wrappedValue = fetchedPosts
                paginationDoc = docs.documents.last
                isFetching = false
            })
        }catch{
            print(error.localizedDescription)
        }
    }
    func fetchUsers() async {
        do {
            let querySnapshot = try await Firestore.firestore().collection("Users").whereField("userid", in: group.userIDs).getDocuments()
            let users = try querySnapshot.documents.compactMap { document -> User? in
                try document.data(as: User.self)
            }
            await MainActor.run {
                fetchedUsers = users
                print(" users were fetched succesfully")
                for user in fetchedUsers {
                    print("\(user.username)")
                }
            }
        } catch {
            print("Error fetching users: \(error.localizedDescription)")
        }
    }

 
}
struct SongCell:View {
    
    @State private var isPresented = false
    var posts:[GrpAudioFiles]
    var grpAudio:GrpAudioFiles
    let refetch:() async -> Void
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var isDownloading = false
    @AppStorage("user_profile_url") private var profileURL: URL?
    @AppStorage("user_name") private var userName:String = ""
    @AppStorage("user_UID") private var userUID:String = ""
    var body: some View {
        VStack{
        
            HStack{
                Button(action:{isPresented = true}){
                    if(userUID != grpAudio.userUID){
                        HStack{
                            HStack{
                                WebImage(url: grpAudio.userProfileURL)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                                    .padding(.leading)
                                    .padding(.bottom)
            //                    ZStack{
            //                        Circle().frame(width: 50,height: 50,alignment: .center).foregroundColor(Color("button-color"))
            //                        Circle().frame(width: 20,height: 20,alignment: .center).foregroundColor(Color.white)
            //
            //                    }
                                VStack(alignment:.leading){
                                    Text(grpAudio.username)
                                        .font(.system(size: 15))
                                        .foregroundStyle(Color.black)
                                    HStack{
                                        Image(systemName: "waveform.badge.plus")
                                            .resizable()
                                            .font(.title3)
                                            .foregroundColor(Color("button-color"))
                                            .frame(width: 25,height: 25)
                                        Text(grpAudio.title)
                                            .font(.system(size: 14))
                                            .foregroundStyle(Color.gray)
                                    }
                                    
                                }
                                
                                
                            }.padding()
                                .background(Color(red: 1.00,green : 0.65,blue: 0.30))
                                .cornerRadius(8)
                                .contextMenu {
                                                    menuItems2
                                                }
                            Spacer()
                        }
                        
                        
                    }
                    else{
                        HStack{
                            Spacer()
                            HStack{
                                        //                    ZStack{
            //                        Circle().frame(width: 50,height: 50,alignment: .center).foregroundColor(Color("button-color"))
            //                        Circle().frame(width: 20,height: 20,alignment: .center).foregroundColor(Color.white)
            //
            //                    }
                                WebImage(url: grpAudio.userProfileURL)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .padding(.bottom)
                                
                                VStack(alignment:.leading){
                                    Text(grpAudio.username)
                                        .font(.system(size: 14.5))
                                        .foregroundStyle(Color.black)
//                                    Text(grpAudio.username)
//                                        .font(.system(size: 12))
//                                        .foregroundStyle(Color.gray)
                                    HStack{
                                        Image(systemName: "waveform")
                                            .resizable()
                                            .font(.title3)
                                            .foregroundColor(Color("button-color"))
                                            .frame(width: 15,height: 15)
                                        Text(grpAudio.title)
                                            .font(.system(size: 16))
                                            .foregroundStyle(Color.white)
                                    }
                                }
                                
                                

                                
                            }
                            .padding()
                            .background(Color(red: 1.00,green : 0.53,blue: 0.30))
                            .cornerRadius(8)
                            .contextMenu {
                                                menuItems
                                            }
                        }
                    }
                }
                
            }
        }
        .sheet(isPresented: $isPresented) {
                    // ProPlayer view presentation
                    ProPlayer(grpAudios: posts, grpAudio: grpAudio)
                .presentationDetents([.height(700)])
                }
        .alert(isPresented: $showAlert) {
                    Alert(title: Text("Deleted"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
    }
    var menuItems: some View {
        Group {
            Button("Download",action:downloadSong)
            Button("Delete",role: .destructive,action: deleteSong)
        }
    }
    var menuItems2: some View {
        Group {
            Button("Download",action:downloadSong)
        }
    }

    
    func deleteSong(){
        Task {
            do{
                
                guard let documentId = grpAudio.id else {
                    alertMessage = "Error: Document ID is missing."
                    showAlert = true
                    return
                }
                if grpAudio.title != ""{
                    if let url = grpAudio.audioURL{
                        try await Storage.storage().reference().child("Group_Audios")
                            .child(grpAudio.audioReferenceID)
                            .delete()
                    }
                }
                
                let firestore = Firestore.firestore()
                firestore.collection("Group_Audios").document(documentId).delete { error in
                    if let error = error {
                        DispatchQueue.main.async {
                            alertMessage = "Deletion error: \(error.localizedDescription)"
                            showAlert = true
                        }
                    } else {
                        DispatchQueue.main.async {
                            alertMessage = "\(grpAudio.title) has been successfully deleted."
                            showAlert = true
                            // Optionally, trigger a refresh of the list if you have such functionality
                        }
                    }
                }
             await refetch()
            }
            catch{
                print(error.localizedDescription)
            }
        }
    }

//    func downloadSong(){
//        if let url = grpAudio.audioURL{
//            let storageRef = Storage.storage().reference(forURL: url.absoluteString)
//            let localURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//            let downloadTask = storageRef.write(toFile: localURL) { url, error in
//              if let error = error {
//                print("Error in download")
//              } else {
//                // Local file URL for "images/island.jpg" is returned
//                  print("downloaded")
//              }
//            }
//        }
        
    func downloadSong() {
        if let url = grpAudio.audioURL {
            let storageRef = Storage.storage().reference(forURL: url.absoluteString)
            let destination = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(url.lastPathComponent).appendingPathExtension("mp3")
            let downloadTask = storageRef.write(toFile: destination) { url, error in
                if let error = error {
                    print("Error in download")
                } else {
                    // Local file URL for "images/island.jpg" is returned
                    print("downloaded")
                    DispatchQueue.main.async {
                        // Present the share sheet
                        let activityViewController = UIActivityViewController(activityItems: [destination], applicationActivities: nil)
                        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
                    }
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
import SwiftUI
import SDWebImageSwiftUI

struct GroupMemberList: View {
    let members: [User]
    @AppStorage("user_profile_url") var profileURL:URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    @AppStorage("log_status") var logStatus:Bool = false
    @State private var searchText = ""
    var body: some View {
        NavigationStack{
            if(members.isEmpty){
                Text("No Members")
                                .foregroundColor(Color.gray.opacity(0.5)) // Apply gray color with 50% opacity

            }
            else{
                ScrollView{
                    VStack{
                        ForEach(members) { member in
                            HStack{
                                WebImage(url: member.userprofileURL)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                                    .padding(.horizontal)
                                Text("\(member.username)")
                                    .font(.title3)
                                Spacer()
                            }
                            Divider()
                        }
                    }
                }
                .navigationTitle("Members")
                .navigationBarTitleDisplayMode(.inline)
                .padding(.vertical)
            }
        }
    }
}
