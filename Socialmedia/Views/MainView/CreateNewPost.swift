//
//  CreateNewPost.swift
//  Overall_Backend
//
//  Created by user4 on 03/03/24.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseStorage
import AVFoundation

struct CreateNewPost: View {
    var onPost: (Post)->()
    @State private var postText: String = ""
    @State private var postImageData: Data?
    @State private var postSongData: Data?
    @State private var audioURL: URL?
    @State private var publishedDate: Date?
    @AppStorage("user_profile_url") private var profileURL: URL?
    @AppStorage("user_name") private var userName:String = ""
    @AppStorage("user_UID") private var userUID:String = ""
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading:Bool = false
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var showAudioPicker = false
    @State private var photoItem: PhotosPickerItem?
    @FocusState private var showkeyboard: Bool
    @State private var photoLibraryAuthorized = false
    @State private var audioAuthorized = false
    @State private var player: AVPlayer?
    @State private var fileURL:URL?
    let instruments = ["Guitar", "Percussion", "Bass", "Piano", "Ensemble", "Saxophone", "Flute", "Trumpet", "EDM", "Music Production"]
        
    let genres = ["Rock", "Pop", "Hip Hop", "Electronic", "Country", "Jazz", "Blues", "Classical", "Metal", "R&B"]
    @State private var selectedInstruments: [String] = []
     @State private var selectedGenre: [String] = []

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
                        Text("Post")
                            .font(.callout)
                            .foregroundStyle(Color.white)
                            .padding(.horizontal,20)
                            .padding(.vertical,6)
                            .background(Color("button-color"),in: Capsule())
                    }.disabledOpacity(postText == "")
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
                        TextField("Whats happening?", text: $postText, axis: .vertical)
                            .focused($showkeyboard)
                        if let postImageData, let image = UIImage(data: postImageData){
                            GeometryReader{
                                let size = $0.size
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: size.width, height: size.height)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                //delete button
                                    .overlay(alignment: .topTrailing){
                                        Button{
                                            withAnimation(.easeInOut(duration: 0.25)){
                                                self.postImageData = nil
                                            }
                                        }label:{
                                            Image(systemName: "trash").tint(.red)
                                                .fontWeight(.bold)
                                        }
                                        .padding(10)
                                    }
                            }
                            .clipped()
                            .frame(height:220)
                            
                        }
                        
                        if let data = postSongData {
                                            AudioPlayerView(data: data)
                                        }
                        VStack{
                                    Text("Select the Instruments used in this artwork")
                                        .font(.headline)
                                        .padding(.top, 20)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(instruments, id: \.self) { instrument in
                                                Button(action: {
                                                    if selectedInstruments.contains(instrument) {
                                                        selectedInstruments.removeAll(where: { $0 == instrument })
                                                    } else {
                                                        selectedInstruments.append(instrument)
                                                    }
                                                }) {
                                                    Text(instrument)
                                                        .padding(.horizontal, 10)
                                                        .padding(.vertical, 5)
                                                        .background(selectedInstruments.contains(instrument) ? Color("button2-color") : Color.gray)
                                                        .foregroundColor(.white)
                                                        .cornerRadius(8)
                                                }
                                            }
                                        }
                                    }
                            Text("Select the Genres this artwork comes under")
                                .font(.headline)
                                .padding(.top, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(genres, id: \.self) { genre in
                                        Button(action: {
                                            if selectedGenre.contains(genre) {
                                                selectedGenre.removeAll(where: { $0 == genre })
                                            } else {
                                                selectedGenre.append(genre)
                                            }
                                        }) {
                                            Text(genre)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(selectedGenre.contains(genre) ? Color("button2-color") : Color.gray)
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                                }
                        
                    }
                    .padding(15)
                }
                Divider()
                HStack{
                    Button{
                        showImagePicker.toggle()
                    }label: {
                        Image(systemName: "photo.on.rectangle")
                            .resizable()
                            .font(.title3)
                            .foregroundColor(Color("button-color"))
                            .frame(width: 60, height:60)
                            .padding(.horizontal)
                            
                    }
                    Button {
                        showAudioPicker = true
                    } label: {
                        Image(systemName: "music.note")
                            .resizable()
                            .font(.title3)
                            .foregroundColor(Color("button-color"))
                            .frame(width: 50, height:60)
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
                            postSongData = data
                        } catch {
                            print("Error reading the selected file: \(error.localizedDescription)")
                        }
                    }
                }
            }
            .vAlign(.top)
            .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
            .onChange(of: photoItem){newValue in
                if let newValue{
                    Task{
                        if let rawImageData = try? await newValue.loadTransferable(type: Data.self
                        ), let image = UIImage(data: rawImageData),let compressedImageData = image.jpegData(compressionQuality: 0.5){
                            //UI Must be done on mainthread
                            await MainActor.run(body: {
                                postImageData = compressedImageData
                                photoItem = nil
                            })
                        }
                    }
                }
            }
            .alert(errorMessage,isPresented: $showError,actions: {})
            //loading View
            .overlay{
                LoadingView(show: $isLoading)
        }
            
        }.onAppear {
            // Request authorization for photo library access
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    // User granted access
                    photoLibraryAuthorized = true
                default:
                    // User denied access or restricted access
                    photoLibraryAuthorized = false
                }
            }
            
            // Request authorization for audio access
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                audioAuthorized = granted
            }
        }
        .alert(isPresented: .constant(!photoLibraryAuthorized || !audioAuthorized)) {
            Alert(
                title: Text("Permission Required"),
                message: Text("Please grant permission to access photos and audio files in settings."),
                primaryButton: .default(Text("Open Settings"), action: {
                    // Open app settings
                    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(settingsURL)
                }),
                secondaryButton: .cancel(Text("Cancel"))
            )
        }
    

    }
    //MARK: Post Content to firebase
    func createPost() {
        isLoading = true
        showkeyboard = false
        Task {
            do {
                guard let profileURL = profileURL else { return }
                let storageref = Storage.storage().reference()

                // Generate unique IDs for image and song references
                let imageReferenceID = "\(userUID)\(Date())"
                let songReferenceID = "\(userUID)\(Date())"

                // Create references for image and song storage
                let imageRef = storageref.child("Post_Images").child(imageReferenceID)
                let songRef = storageref.child("Post_Audios").child(songReferenceID)

                // Variables to hold download URLs for image and song
                var imageURL: URL?
                var songURL: URL?

                // Upload image if available
                if let postImageData {
                    // Upload image data
                    let _ = try await imageRef.putDataAsync(postImageData)
                    // Get download URL for the image
                    imageURL = try await imageRef.downloadURL()
                }

                // Upload song if available
                if let postSongData {
                    // Upload song data
                    let metadata = StorageMetadata()
                    metadata.contentType = "audio/mp3"
                    let _ = try await songRef.putDataAsync(postSongData, metadata: metadata)
                    // Get download URL for the song
                    songURL = try await songRef.downloadURL()
                }

                // Create post object with both image and song URLs
                let post = Post(text: postText,
                                imageURL: imageURL,
                                imageReferenceID: imageReferenceID,
                                songURL: songURL,
                                songReferenceID: songReferenceID,
                                publishedDate: Date(),
                                username: userName,
                                userUID: userUID,
                                userProfileURL: profileURL,userInstruments: selectedInstruments,userGenre: selectedGenre)

                // Create document in Firebase
                try await createDocumentAtFirebase(post)
            } catch {
                await setError(error)
            }
        }
    }

//    func createPost(){
//        isLoading = true
//        showkeyboard = false
//        Task{
//            do{
//                guard let profileURL = profileURL else{return}
//                //step 1 upload image if any
//                //used to delete the post later
//                let imageReferenceID = "\(userUID)\(Date())"
//                let storageref = Storage.storage().reference()
//                let imageRef = storageref.child("Post_Images").child(imageReferenceID)
////.child("Post_Images").child(imageReferenceID)
//                
//               let songReferenceID = "\(userUID)\(Date())"
//               let songRef = storageref.child("Post_Audios").child(songReferenceID)
////               let storageref = Storage.storage().reference().child("Post_Audio").child(songReferenceID)
//                
//                if let postImageData{
//                    
//                    let _ = try await imageRef.putDataAsync(postImageData)
//                    let downloadURL = try await imageRef.downloadURL()
//                    //create post obj with image id and url
//                    let post = Post(text: postText, imageURL: downloadURL,imageReferenceID: imageReferenceID, publishedDate: Date(), username: userName, userUID : userUID, userProfileURL: profileURL)
////                    let post = Post(text: postText, publishedDate: publishedDate! , username: userName, userUID: userUID, userProfileURL: profileURL)
//                    try await createDocumentAtFirebase(post)
//                }
////                else{
////                    //directly post text data to firebase(no imgs present condition)
////                    let post = Post(text: postText,publishedDate: Date(), username: userName, userUID: userUID, userProfileURL: profileURL)
////                    try await createDocumentAtFirebase(post)
////
////                }
//                if let postSongData{
//                    let metadata = StorageMetadata()
//                    metadata.contentType = "audio/mp3"
//                    let _ = try await songRef.putDataAsync(postSongData,metadata: metadata)
//                
//                    let downloadURL = try await songRef.downloadURL()
//
//                    let post = Post(text: postText, imageURL: downloadURL,imageReferenceID: songReferenceID, publishedDate: Date(), username: userName, userUID : userUID, userProfileURL: profileURL)
//
//                    try await createDocumentAtFirebase(post)
//                }
////                else{
////                    //directly post text data to firebase(no imgs present condition)
////                    let post = Post(text: postText,publishedDate: Date(), username: userName, userUID: userUID, userProfileURL: profileURL)
////                    try await createDocumentAtFirebase(post)
////
////                }
//            }catch{
//                await setError(error)
//                
//            }
//        }
//    }
    func createDocumentAtFirebase(_ post: Post)async throws{
        //writing doc into firebase firestore
        let doc = Firestore.firestore().collection("Posts").document()
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



struct AudioPicker: UIViewControllerRepresentable {
    @Binding var audioURL: URL?

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(documentTypes: ["public.audio"], in: .import)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // Add code here to update the `UIDocumentPickerViewController` when the SwiftUI view updates.
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
        var parent: AudioPicker

        init(_ parent: AudioPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.audioURL = url
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.audioURL = nil
            controller.dismiss(animated: true, completion: nil)
        }
    }
}

class Player: ObservableObject {
    let musicData:Data
    @Published var player: AVAudioPlayer?
    @Published var isPlaying = false

    init(data: Data) {
        self.musicData = data
        do {
            self.player = try AVAudioPlayer(data: data)
            self.player?.prepareToPlay()
            self.player?.play()
        } catch {
            print("Error creating AVAudioPlayer: \(error.localizedDescription)")
        }
        
    }

    func playPause() {
        guard let player = player else { return }
        if player.rate == 0 {
            isPlaying = true
            player.play()
        } else {
            isPlaying = false
            player.pause()
        }
    }
}

struct AudioPlayerView: View {
    let data:Data
    @State private var player: AVAudioPlayer?
    @State private var isPlaying = true
    var body: some View {
        VStack {
            Button(action: {
                if isPlaying {
                    player?.pause()
                    isPlaying = false
                } else {
                    player?.play()
                    isPlaying = true
                }
            }) {
                Image(systemName: (!isPlaying) ? "play.fill" : "pause.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color("button2-color"))
            }
        }
        .onAppear {
            do {
                player = try AVAudioPlayer(data: data)
                player?.prepareToPlay()
                player?.play()
            } catch {
                print("Error creating AVAudioPlayer: \(error.localizedDescription)")
            }
            
        }
        .onDisappear {
            player?.pause()
        }
    }
}

#Preview {
    CreateNewPost{_ in
    }
}




