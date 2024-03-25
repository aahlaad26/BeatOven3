//
//  ProPlayer.swift
//  Socialmedia
//
//  Created by user2 on 23/03/24.
//

import Foundation
import SwiftUI
import AVFoundation
import SDWebImageSwiftUI
struct ProPlayer: View {
    @State var grpAudios: [GrpAudioFiles]
    @State var isPlaying: Bool = true
    @State var grpAudio: GrpAudioFiles
    @State var player: AVPlayer?
    @State private var width : CGFloat = UIScreen.main.bounds.height < 750 ? 130 : 230
    @State private var angle : Double = 0
    @State private var totalTime : TimeInterval = 0.0
    @State private var currentTime : TimeInterval = 0.0
    @State private var currentTimeString: String = ""
    var body: some View {
        NavigationView {
            VStack {
                //Slider------------------------------
                ZStack{
                    WebImage(url: grpAudio.userProfileURL)
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
                Text(grpAudio.title)
                    .font(.title2)
                    .fontWeight(.heavy)
                    .foregroundColor(Color.black)
                    .padding(.top,15)
                    .padding(.horizontal)
                Text(grpAudio.username)
                    .foregroundStyle(Color.gray)
                    .padding(.vertical,10)
                    .padding(.horizontal)
                HStack {
                    Button(action: self.prev) {
                        Image(systemName: "backward.fill")
                            .resizable()
                            .frame(width: 50, height: 50, alignment: .center)
                            .padding()
                            .foregroundColor(Color("button2-color"))
                    }
                    
                    Button(action: self.playPause) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50, alignment: .center)
                            .padding()
                            .foregroundColor(Color("button2-color"))
                    }
                    
                    Button(action: self.next) {
                        Image(systemName: "forward.fill")
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
        guard let audioURL = grpAudio.audioURL else {
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
    
    func next() {
        if let currentIndex = grpAudios.firstIndex(of: grpAudio), currentIndex < grpAudios.count - 1 {
            player?.pause()
            grpAudio = grpAudios[currentIndex + 1]
            self.playSong()
            isPlaying = true
        }
    }
    
    func prev() {
        if let currentIndex = grpAudios.firstIndex(of: grpAudio), currentIndex > 0 {
            player?.pause()
            grpAudio = grpAudios[currentIndex - 1]
            self.playSong()
            isPlaying = true
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


