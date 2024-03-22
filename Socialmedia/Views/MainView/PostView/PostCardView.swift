import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseStorage
import AVKit

struct PostCardView: View {
    @State private var player: AVPlayer?
    @State private var user: User?
    var post: Post
    //callbacks
    var onUpdate: (Post)->()
    var onDelete: ()->()
    //view properties
    @AppStorage("user_UID") private var userUID: String = ""
    @State private var docListener: ListenerRegistration? //for live updates

    var body: some View {
        VStack{
            HStack(alignment: .top, spacing: 12){
                
                WebImage(url: post.userProfileURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 35, height: 35)
                    .clipShape(Circle())
                VStack(alignment:.leading){
                    Text(post.username)
                        .font(.callout)
                        .fontWeight(.semibold)
                    if let publishedDate = post.publishedDate {
                        Text(publishedDate.formatted(date: .numeric, time: .shortened))
                            .font(.caption2)
                            .foregroundStyle(Color.gray)
                    }
                    else {
                        Text("No date")
                    }
                }
                Spacer()
                if post.userUID == userUID{
                    Menu{
                        Button("Delete Post", role: .destructive , action: deletePost)
                    }label: {
                        Image(systemName: "ellipsis")
                            .font(.caption)
                            .rotationEffect(.init(degrees: -90))
                            .foregroundStyle(Color.black)
                            .padding(8)
                            .contentShape(Rectangle())
                    }
                    .offset(x:8)
                }
            }.padding(.bottom,10)
                VStack(alignment: .leading, spacing: 6){
                    if let URl = post.imageURL{
                        
                        Text(post.text)
                            .textSelection(.enabled)
                            .padding(.vertical,8)
                        GeometryReader{
                            let size = $0.size
                            WebImage(url: URl)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                        .frame(height: 200)
                        
                        
                        if let songURL = post.songURL {
                            HStack{
                                
                                VStack(alignment:.leading){
                                    Text(post.text)
                                        .textSelection(.enabled)
                                    if let publishedDate = post.publishedDate {
                                        Text(timeSinceDate(date: publishedDate))
                                            .font(.system(size: 10))
                                            .foregroundColor(Color(#colorLiteral(red: 0.42, green: 0.42, blue: 0.42, alpha: 1)))
                                    }
                                }
                                Spacer()
                                PlayerView(player: $player, url: songURL)
                            }.padding()
                            .background(Color("bg-color"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .frame(width: 300)
                        }
                        }
                    
                    PostInteraction()
                }
        }
        .frame(width: UIScreen.main.bounds.width-50)
        .padding()
        .background(Color("cell-color"))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow( radius: 5)
        .hAlign(.leading)
        .overlay(alignment: .topTrailing, content: {})
        .onAppear{
            if docListener == nil {
                guard let postID = post.id else { return }
                docListener = Firestore.firestore().collection("Posts").document(postID).addSnapshotListener({snapshot, error in
                    if let snapshot {
                        if snapshot.exists {
                            if let updatedPost = try? snapshot.data(as: Post.self) {
                                onUpdate(updatedPost)
                            }
                        } else {
                            onDelete()
                        }
                    }
                })
            }
        }
        .onDisappear{
            if let docListener {
                docListener.remove()
                self.docListener = nil
            }
        }
    }
    
    @ViewBuilder
    func PostInteraction()->some View {
        HStack(spacing:20){
            HStack(){
                Button(action: likePost){
                    Image(systemName: post.likedIDs.contains(userUID) ? "heart.fill" : "heart" )
                }
                Text("\(post.likedIDs.count)")
                    .font(.caption)
                    .foregroundStyle(Color.gray)
            }.frame(width: 75,height: 40)
            HStack{
                Button(action: {}){
                    Image(systemName: "bubble.right" )
                }
                Text("\(post.likedIDs.count)")
                    .font(.caption)
                    .foregroundStyle(Color.gray)
            }.frame(width: 75,height: 40)
            HStack{
                Button(action: {}){
                    Image(systemName: "square.and.arrow.down" )
                }
                Text("\(post.likedIDs.count)")
                    .font(.caption)
                    .foregroundStyle(Color.gray)
            }.frame(width: 75,height: 40)
        }
        .frame(width: 300)
        .foregroundStyle(Color.black)
        .padding(.vertical,8)
    }
    
    func likePost(){
        Task{
            guard let postID = post.id else { return }
            if post.likedIDs.contains(userUID) {
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "likedIDs": FieldValue.arrayRemove([userUID])
                ])
            } else {
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "likedIDs": FieldValue.arrayUnion([userUID])
                ])
            }
        }
    }
    
    func deletePost(){
        Task{
            do {
                if post.imageReferenceID != "" {
                    if let URl = post.imageURL {
                        if URl.absoluteString.range(of: "Post_Images") != nil {
                            try await Storage.storage().reference().child("Post_Images").child(post.imageReferenceID).delete()
                        } else {
                            try await Storage.storage().reference().child("Post_Audios").child(post.imageReferenceID).delete()
                        }
                    }
                }
                guard let postID = post.id else { return }
                try await Firestore.firestore().collection("Posts").document(postID).delete()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func timeSinceDate(date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: now)
        
        if let year = components.year, year > 0 {
            return "\(year) year" + (year > 1 ? "s" : "") + " ago"
        }
        if let month = components.month, month > 0 {
            return "\(month) month" + (month > 1 ? "s" : "") + " ago"
        }
        if let day = components.day, day > 0 {
            return "\(day) day" + (day > 1 ? "s" : "") + " ago"
        }
        if let hour = components.hour, hour > 0 {
            return "\(hour) hour" + (hour > 1 ? "s" : "") + " ago"
        }
        if let minute = components.minute, minute > 0 {
            return "\(minute) minute" + (minute > 1 ? "s" : "") + " ago"
        }
        if let second = components.second, second > 0 {
            return "\(second) second" + (second > 1 ? "s" : "") + " ago"
        }
        return "Just now"
    }
}

struct PlayerView: View {
    @Binding var player: AVPlayer?
    let url: URL
    var body: some View {
        VStack {
            AudioPlayerControlsView(player: $player)
        }
        .onAppear {
            if player == nil {
                do {
                    let playerItem:AVPlayerItem = AVPlayerItem(url: url)
                    player = try AVPlayer(playerItem:playerItem)
                } catch {
                    print("Error creating AVAudioPlayer: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct AudioPlayerControlsView: View {
    @Binding var player: AVPlayer?
    @State private var isPlay = true
    var body: some View {
            Button(action: {
                self.playPause()
            }) {
                Image(systemName: isPlay ? "play.fill":"pause.fill")
            }
    }
    func playPause(){
        self.isPlay.toggle()
        if isPlay{
            player?.pause()
        }
        else{
            player?.play()
        }
    }
}
