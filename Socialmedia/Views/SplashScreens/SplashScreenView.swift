//
//  SplashScreenView.swift
//  SplashScreen
//
//  Created by user2 on 27/01/24.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var size = 0.5
    @State private var opacity = 0.5
    var body: some View {
        if isActive {
            StartSplashView()
        }
        else{
            VStack {
                Rectangle()
                  .foregroundColor(.clear)
                  .frame(width: 342.83636, height: 376.81018)
                  .background(
                    Image("img1")
                      .resizable()
                      .aspectRatio(contentMode: .fill)
                      .frame(width: 342.83636474609375, height: 376.8101806640625)
                      .clipped()
                    
                    
                  )
                  .rotationEffect(Angle(degrees: -0.64))
                Text("BeatOven")
                    .font(Font.custom("Condiment-Regular", size: 52)
                        )
                  .foregroundColor(.black)
                  .frame(width: 200, height: 59, alignment: .topLeading)
            }
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                    self.isActive = true
                }
            }
            .frame(width: 393, height: 852)
            .background(Color(red: 0.99, green: 0.87, blue: 0.82))
        }
            
        }
        
}

struct SplashScreenView_Previews: PreviewProvider{
    static var previews: some View{
        SplashScreenView()
    }
}
