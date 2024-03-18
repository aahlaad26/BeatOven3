import SwiftUI
import Firebase

struct FetchPortfolioView: View {
    @AppStorage("user_UID") private var userUID: String = ""
    @State private var portfolioData: PortfolioData?

    var body: some View {
        VStack {
            if let portfolioData = portfolioData {
                Text("Name: \(portfolioData.name)")
                Text("City/Country: \(portfolioData.cityCountry)")
                Text("About Me \(portfolioData.aboutMe)")
                Text("instrument1: \(portfolioData.instrument1)")
                Text("Instrument2: \(portfolioData.instrument2)")
                Text("Instrument3: \(portfolioData.instrument3)")
                Text("Song 1 \(portfolioData.song1)")
                Text("Song 2 \(portfolioData.song2)")
                Text("Song 3 \(portfolioData.song3)")
                Text("Facebook Link \(portfolioData.metalink)")
                Text("Instagram Link \(portfolioData.instalink)")
                Text("Youtube Profile \(portfolioData.ytlink)")
                
                
               
                
                
            } else {
                Text("Loading...")
            }
        }
        .onAppear {
            fetchPortfolioData()
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
        }
    }
}

struct FetchPortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        FetchPortfolioView()
    }
}

