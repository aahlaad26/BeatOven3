import SwiftUI
import UIKit

struct PortfolioView: View {
    @State private var name: String = ""
    @State private var cityCountry: String = ""
    @State private var instrument1: String = ""
    @State private var instrument2: String = ""
    @State private var instrument3: String = ""
    @State private var genre1: String = ""
    @State private var genre2: String = ""
    @State private var genre3: String = ""
    @State private var isAddTextSectionVisible = false
    @State private var isAddSongsSectionVisible = false
    @State private var metalink:String = ""
    @State private var instalink:String = ""
    @State private var ytlink:String = ""
    
    @State private var profileImage: UIImage? // Store the selected profile image
    
    struct SectionView: View {
        let title: String
        @Binding var isVisible: Bool

        var body: some View {
            HStack {
                Image(systemName: "plus")
                Text(title)
                Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .padding([.leading, .trailing])
            .onTapGesture {
                isVisible.toggle()
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                if let image = profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .padding(.leading)
                        .onTapGesture {
                            // Implement logic to change or remove the profile image
                        }
                } else {
                    Button(action: {
                        // Present ImagePicker to select an image
                    }) {
                        Text("Select Profile Image")
                    }
                }

                TextField("Enter Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding([.leading, .trailing])

                TextField("Enter City, Country", text: $cityCountry)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding([.leading, .trailing, .bottom])
                
                TextField("Enter Instrument 1", text: $instrument1)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding([.leading, .trailing, .bottom])

                Text("Sections to Customize")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()

                VStack {
                    SectionView(title: "Add Social Media Profiles", isVisible: $isAddTextSectionVisible)
                    if isAddTextSectionVisible {
                       
                        TextField("Enter Facebook ID Link", text: $metalink)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding([.leading, .trailing, .bottom])
                        TextField("Enter Instagram ID Link", text: $instalink)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding([.leading, .trailing, .bottom]);
                        // Add more fields as needed
                    }

                    SectionView(title: "Add Songs", isVisible: $isAddSongsSectionVisible)
                    if isAddSongsSectionVisible {
                        TextField("Song 1", text: $metalink)
                        TextField("Song 2", text: $ytlink)
                        // Add more fields as needed
                    }
                }
                
                Spacer()

                Button(action: {}) {
                    Text("View current portfolio")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color("button-color"))
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .background(Color(red: 252/255, green: 222/255, blue: 208/255))
        .navigationTitle("Portfolio Creator")
    }
}

struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioView()
    }
}
