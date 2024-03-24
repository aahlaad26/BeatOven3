import SwiftUI
import UIKit
import Firebase
struct PortfolioView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var showCompletionPortfolio = false
    @AppStorage("user_name") private var userName: String = ""
    @AppStorage("user_UID") private var userUID: String = ""
    @State private var id: String = ""
    @State private var name: String = ""
    @State private var cityCountry: String = ""
    @State private var instrument1: String = ""
    @State private var instrument2: String = ""
    @State private var instrument3: String = ""
    @State private var song1: String = ""
    @State private var song2: String = ""
    @State private var song3: String = ""
    @State private var isAddTextSectionVisible = false
    @State private var isAddSongsSectionVisible = false
    @State private var isAddLinksSectionVisible = false
    @State private var metalink:String = ""
    @State private var instalink:String = ""
    @State private var ytlink:String = ""
    @State private var aboutMe:String = ""
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
    func pushDataToFirebase() {
        let db = Firestore.firestore()
        
        let documentReference = db.collection("portfolioData").document(userUID)
        
        let portfolioData = PortfolioData(id: documentReference.documentID, userId: userUID, userName: userName, name: name, cityCountry: cityCountry, instrument1: instrument1, instrument2: instrument2, instrument3: instrument3, song1: song1, song2: song2, song3: song3, aboutMe: aboutMe, metalink: metalink, instalink: instalink, ytlink: ytlink)
        
        do {
            let data = try Firestore.Encoder().encode(portfolioData)
            documentReference.setData(data) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(documentReference.documentID)")
                }
            }
        } catch let error {
            print("Error encoding PortfolioData: \(error)")
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
                
                TextField("Enter Instrument 2", text: $instrument2)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding([.leading, .trailing, .bottom])
                
                
                TextField("Enter Instrument 3", text: $instrument3)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding([.leading, .trailing, .bottom])
                
                Text("Sections to Customize")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                VStack {
                    
                    SectionView(title: "Add Text", isVisible: $isAddTextSectionVisible)
                    if isAddTextSectionVisible {
                        TextEditor(text: $aboutMe)
                            .frame(height: 100)
                            .padding([.leading, .trailing, .bottom])
                            .onChange(of: aboutMe) { newValue in
                                if newValue.count > 150 {
                                    aboutMe = String(newValue.prefix(150))
                                }
                            }
                    }
                    SectionView(title: "Add Social Media Profiles", isVisible: $isAddLinksSectionVisible)
                    if isAddLinksSectionVisible {
                        
                        TextField("Enter Facebook ID Link", text: $metalink)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding([.leading, .trailing, .bottom])
                        TextField("Enter Instagram ID Link", text: $instalink)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding([.leading, .trailing, .bottom]);
                        TextField("Enter Youtube ID Link", text: $ytlink)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding([.leading, .trailing, .bottom]);
                    }
                    
                    SectionView(title: "Add Songs", isVisible: $isAddSongsSectionVisible)
                    if isAddSongsSectionVisible {
                        TextField("Enter Song link 1", text: $song1)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding([.leading, .trailing, .bottom])
                        TextField("Enter Song link 2", text: $song2)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding([.leading, .trailing, .bottom])
                        TextField("Enter Song link 3", text: $song3)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding([.leading, .trailing, .bottom])
                    }
                }
                
                Spacer()
                
                Button(action: {
                    pushDataToFirebase()
                    self.showCompletionPortfolio = true
                }) {
                    Text("Create portfolio")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color("button-color"))
                        .cornerRadius(10)
                }
                .padding()
                .sheet(isPresented: $showCompletionPortfolio) {
                    CompletionPortfolio(presentationMode: _presentationMode)
                }
            }
        }
         
            .navigationTitle("Portfolio Creator")
        }
    }
    

struct CompletionPortfolio: View {
//    var body: some View {
//        VStack {
//            LottieView(name: "new.json")
//            Text("Portfolio Created Succesfully!")
//            
//            NavigationLink(destination: MainView()) {
//                Text("Now BeatOven it")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(Color.blue)
//                    .cornerRadius(10)
//            }
//        }
//    }
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        VStack {
            
            LottieView(name: "new.json")
            Text("Portfolio Created Succesfully!")
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Go Back")
                    
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color("button-color"))
                    .cornerRadius(10)
            }
        }
    }
    
}

    struct PortfolioView_Previews: PreviewProvider {
        static var previews: some View {
            PortfolioView()
        }
    }





