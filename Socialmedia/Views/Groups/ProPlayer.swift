//
//  ProPlayer.swift
//  Socialmedia
//
//  Created by user2 on 23/03/24.
//

import Foundation
import SwiftUI
import AVFoundation
struct ProPlayer : View{
    @State var grpAudios:[GrpAudioFiles]
    @State var isPlaying : Bool = true
    @State var grpAudio:GrpAudioFiles
    @State var player:AVPlayer?
    var body: some View {
        NavigationView{
            VStack{
                
                HStack{
                    Button(action:self.prev){
                        Image (systemName: "backward.fill").resizable()
                            .frame(width: 50, height: 50, alignment: .center)
                            .padding()
                            .foregroundColor(Color("button2-color"))
                    }
                    
                    Button(action:self.playPause){
                        Image (systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill").resizable()
                            .frame(width: 50, height: 50, alignment: .center)
                            .padding()
                            .foregroundColor(Color("button2-color"))
                    }
                    Button(action:self.next){
                        Image (systemName: "forward.fill").resizable()
                            .frame(width: 50, height: 50, alignment: .center)
                            .padding()
                            .foregroundColor(Color("button2-color"))
                    }
                }
            }.onAppear(){
                self.playSong()
            }


        }
        .background(Color("bg-color"))
        .ignoresSafeArea()
    }
    func playSong(){
        player = AVPlayer(playerItem: AVPlayerItem(url: grpAudio.audioURL!))
        player?.play()
    }
    func playPause(){
        isPlaying.toggle()
        if isPlaying==false{
            player?.pause()
        }
        else{
            player?.play()
        }
        
    }
    func next(){
        if let currentIndex = grpAudios.firstIndex(of: grpAudio){
            if currentIndex == grpAudios.count-1{
                
            }
            else{
                player?.pause()
                grpAudio = grpAudios[currentIndex+1]
                self.playSong()
                isPlaying = true
            }
        }
        
    }
    func prev(){
        if let currentIndex = grpAudios.firstIndex(of: grpAudio){
            if currentIndex == 0{
                
            }
            else{
                player?.pause()
                grpAudio = grpAudios[currentIndex-1]
                self.playSong()
                isPlaying = true
            }
        }
    }
}

