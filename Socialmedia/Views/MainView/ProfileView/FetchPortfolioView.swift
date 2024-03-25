import SwiftUI
import Firebase

struct FetchPortfolioView: View {
    @AppStorage("user_UID") private var userUID: String = ""
    @State private var portfolioData: PortfolioData?
    @State private var isLoading: Bool = true
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let portfolioData = portfolioData {
                        Group {
                            Text("Hi, I am  \(portfolioData.name)")
                                .font(.title)
                            Text("About Me: I am from \(portfolioData.cityCountry). \(portfolioData.aboutMe)")
                        }
                       
                        Divider()

                        Text("Instruments Played")
                            .font(.title2)
                            .foregroundColor(.green)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("1. \(portfolioData.instrument1)")
                            Text("2. \(portfolioData.instrument2)")
                            Text("3. \(portfolioData.instrument3)")
                        }
                        Divider()

                        Text("Featured Songs")
                            .font(.title2)
                            .foregroundColor(.purple)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("1. \(portfolioData.song1)")
                            Text("2. \(portfolioData.song2)")
                            Text("3. \(portfolioData.song3)")
                        }
                        Divider()

                        Text("Social Media Links")
                            .font(.title2)
                            .foregroundColor(.orange)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Facebook: \(portfolioData.metalink)")
                            Text("Instagram: \(portfolioData.instalink)")
                            Text("Youtube: \(portfolioData.ytlink)")
                        }
                    } else {
                        Text("Loading...")
                    }
                }
                .padding()
                .onAppear {
                    fetchPortfolioData()
            }
            
            }
            
        }
    }

    func fetchPortfolioData() {
        let db = Firestore.firestore()
        let documentReference = db.collection("portfolioData").document(userUID)

        documentReference.getDocument { (document, error) in
            if let document = document, document.exists {
                do {
                    self.portfolioData = try Firestore.Decoder().decode(PortfolioData.self, from: document.data()!)
                } catch let error {
                    print("Error decoding PortfolioData: \(error)")
                }
            } else {
                print("Document does not exist")
            }
            isLoading = false
        }
    }
}

struct FetchPortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        FetchPortfolioView()
    }
}
