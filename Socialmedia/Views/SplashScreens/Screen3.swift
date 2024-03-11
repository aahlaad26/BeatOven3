import SwiftUI

struct Screen3: View {
    @State private var selectedIndicator = 0
    @State private var isActive = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 10) {
                Spacer()

                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 342.83636, height: 416.81018)
                    .background(
                        Image("scrn3")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 342.83636474609375, height: 406.8101806640625)
                            .clipped()
                            .rotationEffect(Angle(degrees: -0.64))
                    )
                    .padding(.top, 150)

                Spacer()

                Text("Post Tracks and let\npeople find your profile")
                    .font(Font.custom("Holtwood One SC", size: 24))
                    .foregroundColor(.black)
                    .frame(width: 344, height: 193, alignment: .topLeading)
                    .position(x: 200, y: 67)

                Spacer()
            }
            .frame(width: 393, height: 952)
            .background(Color(red: 0.99, green: 0.64, blue: 0.47))
            .cornerRadius(20)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                    // Add any animations or actions on view appear
                }
            }

            Text("BeatOven.")
                .font(Font.custom("Condiment", size: 44))
                .foregroundColor(.black)
                .padding(.top, 100)
                .padding(.trailing, 20)
                .position(x: 310, y: 120)

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
                .position(x: 195, y: 750)

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
                        .padding(.horizontal, 123)
                        .padding(.vertical, 19)
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .padding()
                .position(x: 195, y: 450)

                // Skip Button
                
                Button(action: {
                    isActive = true
                    
                }) {
                    Text("Skip")
                        .foregroundColor(.blue)
                        .font(.system(size: 20, weight: .bold))
                }
                .padding()
                .position(x: 195, y: 190)

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
