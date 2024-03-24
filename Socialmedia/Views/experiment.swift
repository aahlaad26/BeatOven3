//
//  experiment.swift
//  Socialmedia
//
//  Created by mathangy on 24/03/24.
//


import SwiftUI

struct MusicPlayerView: View {
    var body: some View {
        VStack {
            Spacer()
            
            Image("banner")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 300)
                .cornerRadius(20)
                .shadow(radius: 10)
            
            Text("Hidup seperti ini")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            Text("James Adam")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.top, 10)
            
            Text("Indonesian pops")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 5)
            
            Spacer()
            
            HStack {
                Image(systemName: "backward.fill")
                Spacer()
                Image(systemName: "play.fill")
                Spacer()
                Image(systemName: "forward.fill")
            }
            .font(.largeTitle)
            .padding(.horizontal, 50)
            .padding(.bottom, 50)
        }
    }
}

struct MusicPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        MusicPlayerView()
    }
}
