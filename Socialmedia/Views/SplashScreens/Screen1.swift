//
//  Screen1.swift
//  SplashScreen
//
//  Created by user2 on 28/01/24.
//

import SwiftUI

struct Screen1: View {
    @State private var selectedIndicator = 0
    @State private var goToScreen4 = false
    @State private var goToScreen2 = false
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.72, green: 0.9, blue: 0.71)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Image("scrn1")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width * 1) // Make the image responsive by using a percentage of the screen width
                    .padding(.horizontal, 20)
                        

                    Text("BeatOven")
                        .foregroundColor(.black)
                        .font(Font.custom("Condiment", size: 44))
                        .padding(.vertical, 10)

                    Text("Find artists across the world to collaborate.")
                        .foregroundColor(.black)
                        .font(Font.custom("SF Pro Display", size: 24).weight(.bold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)

                    // Indicators
                    HStack(spacing: 10) {
                        ForEach(0..<4) { index in
                            Rectangle()
                                .foregroundColor(index == 0 ? Color(red: 0.99, green: 0.44, blue: 0.44) : Color(red: 0.96, green: 0.96, blue: 0.96))
                                .frame(width: index == 0 ? 30 : 15, height: 15)
                                .cornerRadius(7.5)
                        }
                    }
                    .padding(.bottom, 20)

                    NavigationLink(destination: Screen2().navigationBarBackButtonHidden(true),isActive: $goToScreen2) {
                       
                    }
                    NavigationLink(destination: Screen4().navigationBarBackButtonHidden(true),isActive: $goToScreen4) {
                        EmptyView()
                    }
                    Button(action: {
                        selectedIndicator = 1
                        goToScreen2 = true
                    }){
                        Text("Next")
                            .foregroundColor(.black)
                            .font(.system(size: 20, weight: .bold))
                            .padding()
                            .frame(width: UIScreen.main.bounds.width * 0.8, height: 50)
                            .background(Color.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        goToScreen4 = true
                        // Navigation action to Screen4
                        selectedIndicator = 3
                    }) {
                        Text("Skip")
                            .foregroundColor(.blue)
                            .font(.system(size: 20, weight: .bold))
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#if DEBUG
struct Screen1_Previews: PreviewProvider {
    static var previews: some View {
        Screen1()
    }
}
#endif
