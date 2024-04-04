import SwiftUI

struct Screen3: View {
    @State private var selectedIndicator = 0
    @State private var isActive = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 10) {

                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width:UIScreen.main.bounds.width * 342.83636 / 393, height: UIScreen.main.bounds.height * 416.81018 / 852 )
                    .background(
                        Image("scrn3")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width:UIScreen.main.bounds.width * 342.83636474609375 / 393, height: UIScreen.main.bounds.height * 406.8101806640625 / 852 )
                            .clipped()
                            .rotationEffect(Angle(degrees: -0.64))
                    )
                    .padding(.top, UIScreen.main.bounds.height * 130 / 852)


                Text("Post Tracks and let\npeople find your profile")
                    .foregroundColor(.black)
                    .font(Font.custom("Holtwood One SC", size: 17).weight(.bold))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                    .padding(.top, UIScreen.main.bounds.height * 100 / 852)                    .frame(width:UIScreen.main.bounds.width * 344 / 393, height: UIScreen.main.bounds.height * 193 / 852,alignment: .topLeading)
                    .position(x: UIScreen.main.bounds.width * 200 / 393, y: UIScreen.main.bounds.height * 67 / 852)

            }
            .frame(width:UIScreen.main.bounds.width * 393 / 393, height: UIScreen.main.bounds.height * 952 / 852)
            .background(Color(red: 0.99, green: 0.64, blue: 0.47))
            .cornerRadius(20)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                    // Add any animations or actions on view appear
                }
            }

            Text("BeatOven")
                .font(Font.custom("Condiment", size: 44))
                .foregroundColor(.black)
                .padding(.top, 100)
                .padding(.trailing, 20)
                .position(x: UIScreen.main.bounds.width * 310 / 393, y: UIScreen.main.bounds.height * 120 / 852)
                

            VStack {
                Spacer()

                HStack {
                    Spacer()

                    RectangleIndicator(selected: selectedIndicator == 1)
                        .onTapGesture { selectedIndicator = 0 }

                    RectangleIndicator(selected: selectedIndicator == 1)
                        .onTapGesture { selectedIndicator = 1 }

                    RectangleIndicator(selected: selectedIndicator == 0)
                        .onTapGesture { selectedIndicator = 2 }

                    RectangleIndicator(selected: selectedIndicator == 3)
                        .onTapGesture { selectedIndicator = 3 }

                    Spacer()
                }
                .padding(.bottom, 90)
                .position(x: UIScreen.main.bounds.width * 195 / 393, y: UIScreen.main.bounds.height * 750 / 852)
                NavigationLink(destination: Screen4().navigationBarBackButtonHidden(true), isActive: $isActive) {
                    EmptyView()
                }
                .hidden()

                // Buttons
                // Next Button
                Button(action: {
                    isActive = true
                }) {
                    Text("Next")
                        .foregroundColor(.black)
                        .font(.system(size: 20, weight: .bold))
                        .padding()
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: 50)
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .padding()
                .position(x: UIScreen.main.bounds.width * 195 / 393, y: UIScreen.main.bounds.height * 450 / 852)
                // Skip Button
                
                Button(action: {
                    isActive = true
                    
                }) {
                    Text("Skip")
                        .foregroundColor(.blue)
                        .font(.system(size: 20, weight: .bold))
                }
                .padding()

                .position(x: UIScreen.main.bounds.width * 195 / 393, y: UIScreen.main.bounds.height * 190 / 852)

                NavigationLink(destination: Screen4().navigationBarBackButtonHidden(true), isActive: $isActive) {
                    EmptyView()
                }
                .hidden()
            }
        }
    }
}

struct Screen3_Previews: PreviewProvider {
    static var previews: some View {
        Screen3()
    }
}

struct RectangleIndicator: View {
    var selected: Bool

    var body: some View {
        Rectangle()
            .foregroundColor(selected ? Color(red: 0.99, green: 0.44, blue: 0.44) : Color(red: 0.96, green: 0.96, blue: 0.96))
            .frame(width: selected ? 30 : 15, height: 15)
            .cornerRadius(100)
            .padding(.trailing, 5)
    }
}
