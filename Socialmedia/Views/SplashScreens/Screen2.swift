//import SwiftUI
//
//struct Screen2: View {
//    @State private var selectedIndicator = 0
//    @State private var isActive = false
//    
//
//    var body: some View {
//        ZStack {
//            Image("scrn2")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .padding(.top, 100)
//                .padding(.leading, 20)
//                .frame(width: 1000, height: 700)
//                
//
//            Text("Get your beats fresh from oven")
//                .foregroundColor(.white)
//                .font(Font.custom("SF Pro Display", size: 48).weight(.bold))
//                .padding()
//                .cornerRadius(10)
//                .padding(.top, 50)
//                .position(CGPoint(x: 100.0, y: 150.0))
//                .frame(width: 300)
//
//            Text("BeatOven")
//                .foregroundColor(.black)
//                .font(Font.custom("Condiment", size: 44))
//                .padding()
//                .cornerRadius(10)
//                .padding(.bottom, 50)
//                .padding(.leading, 20)
//                .position(CGPoint(x: 390.0, y: 660.0))
//
//            VStack {
//                Spacer()
//                HStack {
//                    // Indicator 1
//                    Rectangle()
//                        .foregroundColor(.clear)
//                        .frame(width: 15, height: 15)
//                        .background(Color(red: 0.96, green: 0.96, blue: 0.96))
//
//                    .cornerRadius(100)
//                    .onTapGesture {
//                            selectedIndicator = 0
//                        }
//                        .padding(.trailing, 5)
//
//                    // Indicator 2
//                    Rectangle()
//                        .foregroundColor(.clear)
//                        .frame(width: 30, height: 15)
//                        .background(Color(red: 0.99, green: 0.44, blue: 0.44))
//
//                    .cornerRadius(100)
//                    .onTapGesture {
//                            selectedIndicator = 1
//                        }
//                        .padding(.trailing, 5)
//                    
//                    // Indicator 3
//                    Rectangle()
//                    .foregroundColor(.clear)
//                    .frame(width: 15, height: 15)
//                    .background(Color(red: 0.96, green: 0.96, blue: 0.96))
//
//                    .cornerRadius(100)
//                    .onTapGesture {
//                            selectedIndicator = 2
//                        }
//                        .padding(.trailing, 5)
//
//                    // Indicator 3
//                    Rectangle()
//                        .foregroundColor(.clear)
//                        .frame(width: 15, height: 15)
//                        .background(Color(red: 0.96, green: 0.96, blue: 0.96))
//
//                        .cornerRadius(100)
//                        .onTapGesture {
//                            selectedIndicator = 3
//                        }
//                }
//                .padding(.bottom, 25)
//                .position(x:500,y:685)
//                NavigationLink(destination: Screen3().navigationBarBackButtonHidden(true), isActive: $isActive) {
//                    EmptyView()
//                }
//                .hidden()
//
//                Button(action: {
//                    isActive = true
//                }) {
//                    Text("Next")
//                        .foregroundColor(.black)
//                        .font(.system(size: 20, weight: .bold))
//                        .padding(.horizontal, 123)
//                        .padding(.vertical, 19)
//                        .background(Color.white)
//                        .cornerRadius(10)
//                        .frame(width: 300, height: 50)
//                        Spacer()
//                }
//                .position(x:315,y:80)
//                .padding()
//                .frame(width: 500, height: 100)
//                
//                NavigationLink(destination: Screen4().navigationBarBackButtonHidden(true)) {
//                    Text("Skip")
//                        .foregroundColor(.blue)
//                        .font(.system(size: 20, weight: .bold))
//                                                            .cornerRadius(10)
//                        .frame(width: 300, height: 50)
//                }
//                .position(x: 230, y: 30)
//                .padding()
//                .frame(width: 500, height: 100)
//            }
//        }
//        .edgesIgnoringSafeArea(.all)
//        .background(Color(red: 0.48, green: 0.83, blue: 0.65))
//    }
//}
//
//
//
//struct Screen2_Previews: PreviewProvider {
//    static var previews: some View {
//        Screen2()
//    }
//}
//


import SwiftUI

struct Screen2: View {
    @State private var selectedIndicator = 1
    @State private var isActive = false
    @State private var goToScreen3 = false
    var body: some View {
        NavigationView {
            ZStack {
                Color(Color(red: 0.48, green: 0.83, blue: 0.65))
                    .edgesIgnoringSafeArea(.all)
                    
                VStack {
                    Image("scrn2")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width * 1) 
                    
                    Text("BeatOven")
                        .foregroundColor(.black)
                        .font(Font.custom("Condiment", size: 44))
                        .padding(.vertical, 10)

                    Text("Get your beats fresh from oven")
                        .foregroundColor(.black)
                        .font(Font.custom("SF Pro Display", size: 24).weight(.bold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    HStack(spacing: 10) {
                        ForEach(0..<4) { index in
                            Rectangle()
                                .foregroundColor(index == selectedIndicator ? Color(red: 0.99, green: 0.44, blue: 0.44) : Color(red: 0.96, green: 0.96, blue: 0.96))
                                .frame(width: index == selectedIndicator ? 30 : 15, height: 15)
                                .cornerRadius(7.5)
                                .onTapGesture {
                                    selectedIndicator = index
                                }
                        }
                    }
                    .padding(.bottom, 20)

                    NavigationLink(destination: Screen3().navigationBarBackButtonHidden(true), isActive: $goToScreen3) {
                        EmptyView()
                    }
                    NavigationLink(destination: Screen4().navigationBarBackButtonHidden(true),isActive: $isActive) {
                        EmptyView()
                    }
                    Button(action: {goToScreen3 = true}){
                        Text("Next")
                            .foregroundColor(.black)
                            .font(.system(size: 20, weight: .bold))
                            .padding()
                            .frame(width: UIScreen.main.bounds.width * 0.8, height: 50)
                            .background(Color.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        isActive = true
                        // Navigation action to Screen4
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



struct Screen2_Previews: PreviewProvider {
    static var previews: some View {
        Screen2()
    }
}
