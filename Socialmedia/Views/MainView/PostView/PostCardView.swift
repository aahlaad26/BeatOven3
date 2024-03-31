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
    @State private var isPresented = false
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
                        Text(timeSinceDate(date: publishedDate))
                            .font(.system(size: 10))
                            .foregroundColor(Color(#colorLiteral(red: 0.42, green: 0.42, blue: 0.42, alpha: 1)))
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
                                        .font(.system(size: 20))
                                    
                                }
                                Spacer()
                                Button(action: {
                                isPresented = true}) {
                                    Image(systemName:"play.fill")
                                        .resizable()
                                        .frame(width: 25,height: 25)
                                }
                            }.padding()
                            .background(Color("cell2-color"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .frame(width: 340)
                            .padding(.top,5)
                        }
                        VStack{
//                                    Text("Ins")
//                                        .font(.headline)
//                                        .padding(.top, 20)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            if let instruments = post.userInstruments{
                                                ForEach(instruments, id: \.self) { instrument in
                                            
                                                        Text(instrument)
                                                            .padding(.horizontal, 10)
                                                            .padding(.vertical, 5)
                                                            .background(Color("button2-color"))
                                                            .foregroundColor(.white)
                                                            .cornerRadius(8)
                                                    }
                                            }
                                            
                                            }
                                        
                                    }
//                            Text("Select the Genres this artwork comes under")
//                                .font(.headline)
//                                .padding(.top, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    if let genres = post.userGenre{
                                        ForEach(genres, id: \.self) { genre in
                                          
                                                Text(genre)
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 5)
                                                    .background(Color("button2-color"))
                                                    .foregroundColor(.white)
                                                    .cornerRadius(8)
                                            }
                                    }
                                    
                                    }
                                
                            }
                                }
                        }
                    
                    PostInteraction()
                }
        }.sheet(isPresented: $isPresented) {
            // ProPlayer view presentation
            ProPlayer2(post: post)

        }
        .frame(width: UIScreen.main.bounds.width-50)
        .padding()
        .background(Color.white)
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
                        .foregroundStyle(post.likedIDs.contains(userUID) ? Color("button2-color") : Color.black)
                }
                Text("\(post.likedIDs.count)")
                    .font(.caption)
                    .foregroundStyle(post.likedIDs.contains(userUID) ? Color("button2-color") : Color.gray)
            }.frame(width: 75,height: 40)
            HStack{
                Button(action: {}){
                    Image(systemName: "square.and.arrow.down" )
                }
            }.frame(width: 75,height: 40)
            Spacer()
        }
        .frame(width: 340)
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
                        
                            try await Storage.storage().reference().child("Post_Images").child(post.imageReferenceID).delete()
                        if let URl = post.songURL{
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
//
//  ProPlayer.swift
//  Socialmedia
//
//  Created by user2 on 23/03/24.
//


struct ProPlayer2: View {
    @State var isPlaying: Bool = true
    @State var post: Post
    @State var player: AVPlayer?
    @State private var width : CGFloat = UIScreen.main.bounds.height < 750 ? 130 : 230
    @State private var angle : Double = 0
    @State private var currentTimeString: String = ""
    var body: some View {
        NavigationView {
            VStack {
                //Slider------------------------------
                ZStack{
                    WebImage(url: post.imageURL)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width,height: width)
                        .clipShape(Circle())
                    ZStack{
                        Circle()
                            .trim(from: 0,to: 0.8)
                            .stroke(Color.black.opacity(0.06),lineWidth: 4)
                            .frame(width: width + 45, height: width + 45)
                        Circle()
                            .trim(from: 0,to: CGFloat(angle)/360)
                            .stroke(Color("button2-color"),lineWidth: 4)
                            .frame(width: width + 45, height: width + 45)
                        Circle()
                            .fill(Color("button2-color"))
                            .frame(width: 25,height: 25)
                            .offset(x: (width+45)/2)
                            .rotationEffect(.init(degrees: angle))
                            .gesture(DragGesture().onChanged(onSlide(value:)))
                    }
                    .rotationEffect(.init(degrees: 126))
                }
                // Slider--------------------
                Text("\(currentTimeString)")
                Text(post.text)
                    .font(.title2)
                    .fontWeight(.heavy)
                    .foregroundColor(Color.black)
                    .padding(.top,15)
                    .padding(.horizontal)
                Text(post.username)
                    .foregroundStyle(Color.gray)
                    .padding(.vertical,10)
                    .padding(.horizontal)
                HStack {
                    
                    
                    Button(action: self.playPause) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50, alignment: .center)
                            .padding()
                            .foregroundColor(Color("button2-color"))
                    }
                    
                }
            }
            .onAppear() {
                self.playSong()
            }
            .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()){
                _ in updateProgress()
            }
        }
        .background(Color("bg-color"))
        .ignoresSafeArea()
    }
    func onSlide(value: DragGesture.Value) {
        let vector = CGVector(dx: value.location.x, dy: value.location.y)
        let radians = atan2(vector.dy - 12.5, vector.dx - 12.5)
        var tempAngle = radians * 180 / .pi
        tempAngle = tempAngle < 0 ? 360 + tempAngle : tempAngle
        let maxAngle: CGFloat = 288 // Maximum angle representing 100% progress
        
        if tempAngle <= maxAngle {
            self.angle = Double(tempAngle)
            let progress = tempAngle / maxAngle
            if let duration = player?.currentItem?.duration {
                
                
                let totalSeconds = CMTimeGetSeconds(duration)
                let targetTime = totalSeconds * Double(progress)
                player?.seek(to: CMTime(seconds: targetTime, preferredTimescale: 1))
        
            }
        }
    }

    
    func playSong() {
        guard let audioURL = post.songURL else {
            print("Error: Audio URL is nil.")
            return
        }
        
        
        let asset = AVAsset(url: audioURL)
        let durationSeconds = CMTimeGetSeconds(asset.duration)
        let minutes = Int(durationSeconds / 60)
        let seconds = Int(durationSeconds.truncatingRemainder(dividingBy: 60))
        print("Song Duration: \(minutes) minutes \(seconds) seconds")
        
        player = AVPlayer(playerItem: AVPlayerItem(url: audioURL))
        player?.play()
        
    }
    
    func playPause() {
        isPlaying.toggle()
        if isPlaying == false {
            player?.pause()
        } else {
            player?.play()
        }
    }
    
    func updateProgress(){
        guard let totalTime = player?.currentItem?.duration
        else{return}
        if let currentTime = (player?.currentItem?.currentTime()){
            let currentInSecs = CMTimeGetSeconds(currentTime)
            let totalSec = CMTimeGetSeconds(totalTime)
            self.angle = 288 * currentInSecs/totalSec
            self.currentTimeString = timeString(time: currentInSecs)
        }
    }
    func timeString(time: Double) -> String{
        
        let minutes = Int(time / 60)
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        return String(format :"%02d:%02d",minutes,seconds)
    }
}


