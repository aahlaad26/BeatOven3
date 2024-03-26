import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore

struct SearchUserView: View {
    // View properties
    @State private var fetchedUsers: [User] = []
    @State private var searchedUsers: [User] = []
    @State private var searchText: String = ""
    @State private var posts: [Post] = []
    @Environment(\.dismiss) private var dismiss
    @AppStorage("user_profile_url") var profileURL:URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    @AppStorage("log_status") var logStatus:Bool = false
    let instruments = ["Guitar", "Percussion", "Bass", "Piano", "Ensemble", "Saxophone", "Flute", "Trumpet", "EDM", "Music Production"]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(searchedUsers) { user in
                    if(user.userid != userUID){
                        NavigationLink(destination: ReusableProfileContent(posts: $posts, user: user)) {
    //                        Text(user.username)
    //                            .font(.callout)
    //                            .hAlign(.leading)
                            HStack{
                                WebImage(url: user.userprofileURL)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                VStack(alignment: .leading){
                                    Text(user.username)
                                        .fontWeight(.semibold)
                                }
                                .padding(.vertical)
                                Spacer()
                            }
                        }
                    }
                }
                .listRowBackground(Color.clear)
                
                ForEach(instruments, id: \.self) { instrument in
                    Section(header: Text("Find \(instrument) artists")) {
                        ForEach(fetchedUsers.filter { $0.selectedInstruments?.contains(instrument) ?? false }) { user in
                            if user.userid != userUID{
                                NavigationLink(destination: ReusableProfileContent(posts: $posts, user: user)) {
    //                                Text(user.username)
    //                                    .font(.callout)
    //                                    .hAlign(.leading)
                                    HStack{
                                        WebImage(url: user.userprofileURL)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                        VStack(alignment: .leading){
                                            Text(user.username)
                                                .fontWeight(.semibold)
                                        }
                                        .padding(.vertical)
                                        Spacer()
                                    }
                                }
                            }
                            
                        }
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Search User")
            .searchable(text: $searchText)
            .onChange(of: searchText) { newValue in
                if newValue.isEmpty {
                    searchedUsers = []
                } else {
                    searchedUsers = fetchedUsers.filter { $0.username.localizedCaseInsensitiveContains(newValue) }
                }
            }
            .onAppear {
                Task {
                    await searchUsers()
                }
            }
            .scrollContentBackground(.hidden)
        }
    }
    
    func searchUsers() async {
        do {
            let querySnapshot = try await Firestore.firestore().collection("Users").getDocuments()
            let users = try querySnapshot.documents.compactMap { document -> User? in
                try document.data(as: User.self)
            }
            await MainActor.run {
                fetchedUsers = users
            }
        } catch {
            print("Error fetching users: \(error.localizedDescription)")
        }
    }
}

struct SearchUserView_Previews: PreviewProvider {
    static var previews: some View {
        SearchUserView()
    }
}
