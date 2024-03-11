//
//  Screen4.swift
//  SplashScreen
//
//  Created by user2 on 30/01/24.
//

import SwiftUI

struct Screen4: View {
    @State private var selectedIndicator = 0
    @State private var fadeIn = false
    @State private var isActive = false
    var body: some View {
        NavigationView {
                
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 10) {
                    Spacer()

                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 342.83636, height: 376.81018)
                        .background(
                            Image("scrn4")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 342.83636474609375, height: 476.8101806640625)
                                .clipped()
                                .opacity(fadeIn ? 1.0 : 0.0) // Fade-in animation
                                .rotationEffect(Angle(degrees: -0.64))
                        )
                        .padding(.top, 150) // Adjust the padding to bring the image down

                    Spacer()

                    Text("Your music deserves to be heard\nBuild Your Portfolio Now!")
                        .font(Font.custom("SF Pro Display", size: 31))
                        .frame(width: 344, height: 193, alignment: .topLeading)
                        .opacity(fadeIn ? 1.0 : 0.0) // Fade-in animation
                        .offset(y: fadeIn ? 0 : -20) // Vertical animation
                        .position(x:200,y:105)

                    Spacer()
                    
                }
                .frame(width: 393, height: 952)
                .background(Color(red: 0.90, green: 0.70, blue: 0.7))
                .cornerRadius(20)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        fadeIn.toggle()
                    }
                }

                // Add "BeatOven" text at the top-right corner
                Text("BeatOven.")
                    .font(Font.custom("Condiment", size: 44))
                    .foregroundColor(.black)
                    .padding(.top, 100)
                    .padding(.trailing, 20)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer() // Center the indicators horizontally

                        // Indicator 1
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 15, height: 15)
                            .background(Color(red: 0.96, green: 0.96, blue: 0.96))
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
                            .frame(width: 30, height: 15)
                            .background(Color(red: 0.99, green: 0.44, blue: 0.44))
                            .cornerRadius(100)
                            .onTapGesture {
                                selectedIndicator = 3
                            }
                            .padding(.trailing, 5)
                        
                        
                        
                        Spacer() // Center the indicators horizontally
                    }
                    .padding(.bottom, 90)
                    NavigationLink(destination: LoginView().navigationBarBackButtonHidden(true), isActive: $isActive) {
                        EmptyView()
                    }
                    Button(action: {
                        isActive = true
                        
                    }) {
                        
                        Text("Get Started")
                            .frame(width: 300, height: 50)
                            .foregroundColor(.black)
                            .font(.system(size: 20, weight: .bold))
                            .background(Color.white)
                            .cornerRadius(10)
                            
                    }
                    
                    .position(x:140,y:-70)
                    .padding()
                    .frame(width: 300, height: 100)
                }
            }

            
            
        }
    }
}

#Preview {
    Screen4()
}
