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
                if searchedUsers.isEmpty{
                    ForEach(instruments, id: \.self) { instrument in
                        Section(header: Text("Find \(instrument) artists")
                            .padding(.horizontal,10)) {
                            ScrollView(.horizontal){
                                HStack{
                                    ForEach(fetchedUsers.filter { $0.selectedInstruments?.contains(instrument) ?? false }) { user in
                                        if user.userid != userUID{
                                            NavigationLink(destination: ReusableProfileContent(posts: $posts, user: user)) {
                //                                Text(user.username)
                //                                    .font(.callout)
                //                                    .hAlign(.leading)
                                                VStack{
                                                    WebImage(url: user.userprofileURL)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 100, height: 100)
                                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                                        .padding(.vertical)
                                                    VStack(alignment: .leading){
                                                        Text(user.username)
                                                            .fontWeight(.semibold)
                                                            .foregroundStyle(Color.black)
                                                    }
                                                    .padding(.vertical)
                                                    
                                                }
                                                .frame(width: 150, height: 150)
                                                .padding()
                                                .background(Color.white)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .shadow( radius: 5)
                                                .padding(.horizontal,10)
                                                                                        }
                                        }
                                        
                                    }
                                }.padding(.vertical)
                                    .padding(.horizontal,10)
                                
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                else{
                    Section(header: Text("Searched artists")
                        .padding(.horizontal,10)) {
                        ScrollView(.horizontal){
                            HStack{
                                ForEach(searchedUsers) { user in
                                    if user.userid != userUID{
                                        NavigationLink(destination: ReusableProfileContent(posts: $posts, user: user)) {
            //                                Text(user.username)
            //                                    .font(.callout)
            //                                    .hAlign(.leading)
                                            VStack{
                                                WebImage(url: user.userprofileURL)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 100, height: 100)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                                    .padding(.vertical)
                                                VStack(alignment: .leading){
                                                    Text(user.username)
                                                        .fontWeight(.semibold)
                                                        .foregroundStyle(Color.black)
                                                }
                                                .padding(.vertical)
                                                
                                            }
                                            .frame(width: 150, height: 150)
                                            .padding()
                                            .background(Color.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .shadow( radius: 5)
                                            .padding(.horizontal,10)
                                                                                    }
                                    }
                                    
                                }
                            }.padding(.vertical)
                                .padding(.horizontal,10)
                            
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
