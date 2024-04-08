//
//  CreateAudioFileView.swift
//  Socialmedia
//
//  Created by mathangy on 21/03/24.
//



import SwiftUI

import Firebase
import FirebaseStorage
import AVFoundation
struct CreateAudioFileView: View {
       var group:Groupped
        let refetch:() async -> Void
        var am:AlertModel
        var onPost: (GrpAudioFiles)->()
        @State private var audioTitle: String = ""
       
        @State private var audioData: Data?
        @State private var audioURL: URL?
        @State private var publishedDate: Date?
        @AppStorage("user_profile_url") private var profileURL: URL?
        @AppStorage("user_name") private var userName:String = ""
        @AppStorage("user_UID") private var userUID:String = ""
        @Environment(\.dismiss) private var dismiss
        @State private var isLoading:Bool = false
        @State private var errorMessage: String = ""
        @State private var showError: Bool = false
        @State private var showAudioPicker = false
     
        @FocusState private var showkeyboard: Bool
        @State private var player: AVPlayer?
        @State private var fileURL:URL?
        
        var body: some View {
            ZStack {
                VStack{
                    HStack{
                        Menu{
                            Button("Cancel",role: .destructive){
                                dismiss()
                            }
                        }label:{
                            Text("Cancel").font(.callout)
                                .foregroundStyle(Color.black)
                        }
                        .hAlign(.leading)
                        Button(action:createPost){
                            Text("Add")
                                .font(.callout)
                                .foregroundStyle(Color.white)
                                .padding(.horizontal,20)
                                .padding(.vertical,6)
                                .background(Color("button-color"),in: Capsule())
                        }.disabledOpacity(audioTitle == "")
                    }
                    .padding(.horizontal,15)
                    .padding(.vertical,10)
                    .background{
                        Rectangle()
                            .fill(.gray.opacity(0.05))
                            .ignoresSafeArea()
                    }
                    ScrollView(.vertical, showsIndicators: false){
                        VStack(spacing: 15){
                            TextField("Give a title to your masterpiece", text: $audioTitle, axis: .vertical)
                                .focused($showkeyboard)
                           
                            if let data = audioData {
                                                AudioPlayerView(data: data)
                                            }
                        }
                        .padding(15)
                    }
                    Divider()
                    HStack{
                       
                        Button {
                            showAudioPicker = true
                        } label: {
                            Image(systemName: "waveform.badge.plus")
                                .resizable()
                                .font(.title3)
                                .foregroundColor(Color("button-color"))
                                .frame(width: 50, height:50)
                                .padding(.horizontal)
                        }.fileImporter(
                            isPresented: $showAudioPicker,
                            allowedContentTypes: [.audio],
                            allowsMultipleSelection: false
                        ) { result in
                            do {
                                let fileURL = try result.get().first!
                                self.fileURL = fileURL
                                let data = try Data(contentsOf: fileURL)
                                audioData = data
                            } catch {
                                print("Error reading the selected file: \(error.localizedDescription)")
                            }
                        }
                    }
                }
                .vAlign(.top)
                
               
                .alert(errorMessage,isPresented: $showError,actions: {})
                //loading View
                .overlay{
                    LoadingView(show: $isLoading)
            }
            }
        }
        //MARK: Post Content to firebase
        func createPost(){
            isLoading = true
            showkeyboard = false
            Task{
                do{
                    guard let profileURL = profileURL else{return}
                    //step 1 upload image if any
                    //used to delete the post later
                   
                    let storageref = Storage.storage().reference()
                   
                    
                   let audioReferenceID = "\(userUID)\(Date())"
                   let audioRef = storageref.child("Group_Audios").child(audioReferenceID)

                    
                    if let audioData{
                        let metadata = StorageMetadata()
                        metadata.contentType = "audio/mp3"
                        let _ = try await audioRef.putDataAsync(audioData,metadata: metadata)
                    
                        let downloadURL = try await audioRef.downloadURL()

//                        let post = Post(text: postText, imageURL: downloadURL,imageReferenceID: songReferenceID, publishedDate: Date(), username: userName, userUID : userUID, userProfileURL: profileURL)
                        let audio = GrpAudioFiles(title: audioTitle, audioURL: downloadURL  ,audioReferenceID: audioReferenceID,publishedDate: Date(), username: userName, userUID: userUID, userProfileURL: profileURL, groupID:group.id )
                        try await createDocumentAtFirebase(audio)
                    }
                  await refetch()
                    am.alertPresented = true
                }
                
                catch{
                    await setError(error)
                    
                }
            }
        }
        func createDocumentAtFirebase(_ post: GrpAudioFiles)async throws{
            //writing doc into firebase firestore
            let doc = Firestore.firestore().collection("Group_Audios").document()
            let _ = try doc.setData(from: post, completion: {error in
                if error == nil{
                    //post successfully stored at firebase
                    isLoading = false
                    var updatedPost = post
                    updatedPost.id = doc.documentID
                    onPost(updatedPost)
                    dismiss()
                }
            })
            
        }
        //MARK: Displaying errors as alerts
        
        func setError(_ error: Error) async{
            await MainActor.run(body: {
                errorMessage = error.localizedDescription
                showError.toggle()
            })
        }
    }


//#Preview {
//    CreateAudioFileView(group: <#Groupped#>){_ in
//
//    }
//}



















