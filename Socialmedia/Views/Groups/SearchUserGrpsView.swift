//
//  SearchUserGrpsView.swift
//  Socialmedia
//
//  Created by user2 on 19/03/24.
//
import SwiftUI
import Firebase
import FirebaseFirestore
import SDWebImageSwiftUI

struct SearchUserGrpsView: View {
    @State private var fetchedUsers: [User] = []
    @State private var searchText: String = ""
    @State private var selectedUsers: Set<User> = []
    @ObservedObject var ID = UserIDs()

    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                                   HStack(spacing: 8) {
                                       ForEach(Array(selectedUsers), id: \.self) { user in
                                           VStack {
                                               ZStack(alignment: .topTrailing) {
                                                                                   WebImage(url: user.userprofileURL)
                                                                                       .resizable()
                                                                                       .aspectRatio(contentMode: .fill)
                                                                                       .frame(width: 50, height: 50)
                                                                                       .clipShape(Circle())

                                                                                   Button(action: {
                                                                                       selectedUsers.remove(user)
                                                                                       ID.removeUser(name: user.userid)
                                                                                   }) {
                                                                                       Image(systemName: "xmark.circle.fill")
                                                                                           .foregroundColor(.red)
                                                                                           .padding(4)
                                                                                           .background(Color.white)
                                                                                           .clipShape(Circle())
                                                                                   }
                                                                                   .padding(.trailing, -10)
                                                                                   .padding(.top, -10)
                                                                               }
                                               .padding(.top)
                                               Text(user.username)
                                                   .font(.caption)
                                                   .fontWeight(.semibold)
                                           }
                                       }
                                   }
                                   .padding(.horizontal)
                }
                               .padding(.vertical, 15)
                            
                
                List {
                    ForEach(fetchedUsers) { user in
                        CheckboxRow(user: user, isSelected: selectedUsers.contains(user)) { isChecked in
                            if isChecked {
                                selectedUsers.insert(user)
                                ID.addUser(name: user.userid)
                            } else {
                                selectedUsers.remove(user)
                                ID.removeUser(name: user.userid)
                            }
                            
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Search User")
                .searchable(text: $searchText)
                .onSubmit(of: .search) {
                    Task {
                        await searchUsers()
                    }
                }
                .onChange(of: searchText) { newValue in
                    if newValue.isEmpty {
                        fetchedUsers = []
                    }
                }
            .scrollContentBackground(.hidden)
            }
        }
    }

    func searchUsers() async {
        do {
            let documents = try await Firestore.firestore()
                .collection("Users")
                .whereField("username", isGreaterThanOrEqualTo: searchText)
                .whereField("username", isLessThanOrEqualTo: "\(searchText)\u{f8ff}")
                .getDocuments()

            let users = try documents.documents.compactMap { doc -> User? in
                try doc.data(as: User.self)
            }

            await MainActor.run {
                fetchedUsers = users
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct CheckboxRow: View {
    let user: User
    let isSelected: Bool
    let action: (Bool) -> Void

    var body: some View {
        Button(action: {
            action(!isSelected)
        }) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? .blue : .gray)
                WebImage(url: user.userprofileURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 6) {
                    Text(user.username)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text(user.userbio)
                        .font(.caption)
                        .foregroundColor(Color.gray)
                        .lineLimit(3)
                    if let bioLink = URL(string: user.userbiolink) {
                        Link(user.userbiolink, destination: bioLink)
                            .font(.callout)
                            .foregroundColor(.blue)
                            .lineLimit(1)
                    }
                }
                .hAlign(.leading)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SearchUserGrpsView()
}
