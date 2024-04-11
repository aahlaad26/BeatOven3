import SwiftUI
import Firebase
import PDFKit
import SDWebImageSwiftUI
struct FetchPortfolioView: View {
    @AppStorage("user_UID") private var userUID: String = ""
    @State private var portfolioData: PortfolioData?
    @State private var isLoading: Bool = true
    @State private var pdfData: Data?
    @State private var isPresentingShareSheet: Bool = false
    var user: User

    var body: some View {
        NavigationView {
            ScrollView {
                VStack{
                    WebImage(url: user.userprofileURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100 , height: 100)
                    .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 20) {
                        if let portfolioData = portfolioData {
                            Group {
//                                Text("Hi, I am  \(portfolioData.name) and you can call me \(user.username)")
//                                    .font(.title)
                                VStack(alignment: .leading) {
                                    Text("Hi, I am \(portfolioData.name)")
                                        
                                        .font(Font.custom("Whisper-Regular", size: 20))
                                    HStack {
                                        Text("You can call me")
                                            .font(.title)
                                        TypingText(text: "\(user.username)", speed: 0.22)
                                            .font(.title)
                                    }
                                }


                                Text("From  \(portfolioData.cityCountry) 📌 \n\(portfolioData.aboutMe)")
                            }
                           
                            Divider()
//                            Text("Hi, I am \(portfolioData.name)")
//                                
//                                .font(Font.custom("Whisper-Regular", size: 20))
                            Text("Instruments I play 🎹")
                                .font(Font.custom("Whisper-Regular", size: 20))
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

    //                        Text("Social Media Links")
    //                            .font(.title2)
    //                            .foregroundColor(.orange)
    //                        VStack(alignment: .leading, spacing: 5) {
    //                            Text("Facebook: \(portfolioData.metalink)")
    //                            Text("Instagram: \(portfolioData.instalink)")
    //                            Text("Youtube: \(portfolioData.ytlink)")
    //                        }
                            Text("Social Media Links")
                                            .font(.title2)
                                            .foregroundColor(.orange)
                            HStack(alignment: .top, spacing: 5) {
                                SocialMediaButton(iconName: "facebook", link: portfolioData.metalink)
                                SocialMediaButton(iconName: "instagram", link: portfolioData.instalink)
                                SocialMediaButton(iconName: "youtube", link: portfolioData.ytlink)
                            }


                            Button(action: {
                                generatePDF()
                            }) {
                                Text("Download as PDF")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        } else {
                            Text("No Portfolio Found")
                        }
                
                    }
                    .padding()
                }
            }
            .navigationTitle("Portfolio")
            .onAppear {
                fetchPortfolioData(userId: user.userid)
            }
        }
        .sheet(isPresented: $isPresentingShareSheet) {
            ShareSheet(activityItems: [pdfData as Any])
        }
    }

    func fetchPortfolioData(userId: String) {
        let db = Firestore.firestore()
        let documentReference = db.collection("portfolioData").document(userId)

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
    func generatePDF() {
        let pdfData = NSMutableData()

        // Create PDF context
        UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, nil)

        // Begin new page
        UIGraphicsBeginPDFPageWithInfo(CGRect(x: 0, y: 0, width: 612, height: 792), nil)

        // Draw view to PDF context
        let pdfView = UIHostingController(rootView: FetchPortfolioView(user: user))
        pdfView.view.frame = CGRect(x: 0, y: 0, width: 612, height: 792)
        if let pdfContext = UIGraphicsGetCurrentContext() {
            pdfView.view.layer.render(in: pdfContext)
        }

        // End PDF context
        UIGraphicsEndPDFContext()

        // Set PDF data
        self.pdfData = pdfData as Data

        // Present share sheet
        isPresentingShareSheet = true
    }

}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct PDFContentView: View {
    let portfolioData: PortfolioData

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Hi, I am \(portfolioData.name)")
                .font(.title)
            Text("About Me: I am from \(portfolioData.cityCountry). \(portfolioData.aboutMe)")

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
        }
        .padding()
    }
}

struct SocialMediaButton: View {
    let iconName: String
    let link: String

    var body: some View {
        Button(action: {
            if let url = URL(string: link) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }) {
            Image(iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32) // Adjust size as needed
                .foregroundColor(.blue)
        }
    }
}


struct PortfolioFetchView: View {
    @AppStorage("user_UID") private var userUID: String = ""
    @State private var portfolioData: PortfolioData?
    @State private var isLoading: Bool = true
    @State private var pdfData: Data?
    @State private var isPresentingShareSheet: Bool = false
    var user: User
    
    var body: some View {
        NavigationView {
            ScrollView {
                if let portfolioData = portfolioData {
                    PDFContentView(portfolioData: portfolioData)
                } else {
                    Text("No Portfolio Found")
                        .padding()
                }
            }
            .navigationTitle("Portfolio Details")
            .onAppear {
                fetchPortfolioData(userId: user.userid)
            }
        }
        .sheet(isPresented: $isPresentingShareSheet) {
            ShareSheet(activityItems: [pdfData as Any])
        }
    }
    
    func fetchPortfolioData(userId: String) {
        let db = Firestore.firestore()
        let documentReference = db.collection("portfolioData").document(userId)
        
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

    func generatePDF() {
        guard let portfolioData = portfolioData else { return }
        let pdfData = NSMutableData()

        // Create PDF context
        UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, nil)

        // Begin new page
        UIGraphicsBeginPDFPageWithInfo(CGRect(x: 0, y: 0, width: 612, height: 792), nil)

        // Draw view to PDF context
        let pdfContentView = PDFContentView(portfolioData: portfolioData)
        let pdfView = UIHostingController(rootView: pdfContentView)
        pdfView.view.frame = CGRect(x: 0, y: 0, width: 612, height: 792)

        DispatchQueue.main.async {
            let snapshot = pdfView.view.snapshot()
            if let pdfContext = UIGraphicsGetCurrentContext(), let cgImage = snapshot?.cgImage {
                pdfContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: 612, height: 792))
            }

            // End PDF context
            UIGraphicsEndPDFContext()

            // Set PDF data
            self.pdfData = pdfData as Data

            // Present share sheet
            self.isPresentingShareSheet = true
        }
    }

        
        //    func generatePDF() {
        //        guard let portfolioData = portfolioData else { return }
        //        let pdfData = NSMutableData()
        //
        //        // Create PDF context
        //        UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, nil)
        //
        //        // Begin new page
        //        UIGraphicsBeginPDFPageWithInfo(CGRect(x: 0, y: 0, width: 612, height: 792), nil)
        //
        //        // Draw view to PDF context
        //        let pdfContentView = PDFContentView(portfolioData: portfolioData)
        //        let pdfView = UIHostingController(rootView: pdfContentView)
        //        pdfView.view.frame = CGRect(x: 0, y: 0, width: 612, height: 792)
        //        if let pdfContext = UIGraphicsGetCurrentContext() {
        //            pdfView.view.layer.render(in: pdfContext)
        //        }
        //
        //        // End PDF context
        //        UIGraphicsEndPDFContext()
        //
        //        // Set PDF data
        //        self.pdfData = pdfData as Data
        //
        //        // Present share sheet
        //        isPresentingShareSheet = true
        //    }
    }

extension UIView {
    func snapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}






struct TypingText: View {
    let text: String
    let speed: Double
    @State private var displayText = ""
    @State private var timer: Timer? = nil
    @State private var isAnimating = true

    var body: some View {
        Text(displayText)
            .font(.title)
            .onTapGesture {
                isAnimating.toggle()
                if isAnimating {
                    startAnimation()
                } else {
                    stopAnimation()
                }
            }
            .onAppear {
                startAnimation()
            }
            .onDisappear {
                stopAnimation()
            }
    }

    private func startAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { _ in
            if displayText.count < text.count {
                let index = text.index(text.startIndex, offsetBy: displayText.count)
                displayText.append(text[index])
            } else {
                displayText = ""
            }
        }
    }

    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }
}
