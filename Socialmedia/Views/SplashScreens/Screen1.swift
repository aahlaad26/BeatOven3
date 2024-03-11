//
//  Screen1.swift
//  SplashScreen
//
//  Created by user2 on 28/01/24.
//

import SwiftUI

struct Screen1: View {
    @State private var selectedIndicator = 0
    

    var body: some View {
        NavigationView {
            ZStack {
                Image("scrn1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.top, 100)
                    .padding(.leading, 20)
                    .frame(width: 1000, height: 800)
                    .position(CGPoint(x: 250.0, y: 300.0))

                Text("BeatOven")
                    .foregroundColor(.black)
                    .font(Font.custom("Condiment", size: 44))
                    .padding()
                    .cornerRadius(10)
                    .padding(.top, 50)
                    .position(CGPoint(x: 40.0, y: 80.0))
                    .frame(width: 300)

                Text("Find artists across the world to collaborate. ")
                    .foregroundColor(.black)
                    .font(Font.custom("SF Pro Display", size: 38).weight(.bold))
                    .padding()
                    .cornerRadius(10)
                    .padding(.bottom, 50)
                    .padding(.leading, 20)
                    .position(CGPoint(x: 230.0, y: 610.0))

                VStack(spacing: 0) {
                    Spacer()

                    HStack {
                        // Indicator 1
                        Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 30, height: 15)
                        .background(Color(red: 0.99, green: 0.44, blue: 0.44))

                        .cornerRadius(100)
                        .onTapGesture {
                                selectedIndicator = 0
                            }
                            .padding(.trailing, 5)

                        // Indicator 2
                        Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 15, height: 15)
                        .background(Color(red: 0.96, green: 0.96, blue: 0.96))

                        .cornerRadius(100)
                        .onTapGesture {
                                selectedIndicator = 1
                            }
                            .padding(.trailing, 5)
                        
                        // Indicator 3
                        Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 15, height: 15)
                        .background(Color(red: 0.96, green: 0.96, blue: 0.96))

                        .cornerRadius(100)
                        .onTapGesture {
                                selectedIndicator = 2
                            }
                            .padding(.trailing, 5)

                        // Indicator 4
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 15, height: 15)
                            .background(Color(red: 0.96, green: 0.96, blue: 0.96))

                            .cornerRadius(100)
                            .onTapGesture {
                                selectedIndicator = 3
                            }
                    }
                    
                    .padding(.bottom, 25)
                    .position(x:250,y:685)

                    NavigationLink(destination: Screen2().navigationBarBackButtonHidden(true) ){
                        Text("Next")
                            .foregroundColor(.black)
                            .font(.system(size: 20, weight: .bold))
                            .padding(.horizontal, 123)
                            .padding(.vertical, 19)
                            .background(Color.white)
                            .cornerRadius(10)
                            .frame(width: 300, height: 50)
                    }
                    .position(x: 230, y: 70)
                    .padding()
                    .frame(width: 500, height: 100)
                    
                    NavigationLink(destination: Screen4().navigationBarBackButtonHidden(true)) {
                        Text("Skip")
                            .foregroundColor(.blue)
                            .font(.system(size: 20, weight: .bold))
                                                                .cornerRadius(10)
                            .frame(width: 300, height: 50)
                    }
                    .position(x: 230, y: 30)
                    .padding()
                    .frame(width: 500, height: 100)


                    
                }
            }
            .edgesIgnoringSafeArea(.all)
            .background(Color(red: 0.72, green: 0.9, blue: 0.71))
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct Constants1 {
    static let PrimaryTextColor: Color = Color(red: 0.14, green: 0.15, blue: 0.19)
}

#if DEBUG
struct Screen1_Previews: PreviewProvider {
    static var previews: some View {
        Screen1()
    }
}
#endif
