//
//  NotificationView.swift
//  Socialmedia
//
//  Created by mathangy on 05/04/24.
//

import SwiftUI
import Firebase
import FirebaseStorage
import SDWebImageSwiftUI
struct NotificationView: View {
    @State private var isFetching = false
    @State private var notifys : [Notification] = []
    @AppStorage("user_profile_url") var profileURL:URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    @AppStorage("log_status") var logStatus:Bool = false
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack{
                    if(notifys.isEmpty){
                        Text("No notifications")
                    }
                    ForEach(notifys){notif in
                        VStack{
                            HStack{
                                WebImage(url: notif.fromUserProfileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                                Text("Accept \(notif.fromUsername)'s group request")
                                    .font(.subheadline)
                                Spacer()
                                HStack{
                                    Button(action: {Task{
                                        try await Firestore.firestore().collection("notification").document(notif.id).updateData(["dismissStatus" : true])
                                        try await Firestore.firestore().collection("groups").document(notif.groupID).updateData([
                                                "userIDs": FieldValue.arrayUnion([userUID])
                                            ])
                                        try await Firestore.firestore().collection("groups").document(notif.groupID).updateData([
                                                "requests": FieldValue.arrayRemove([userUID])
                                            ])
                                        await fetchNotfications()
                                    }
                                    }){
                                        Text("Accept")
                                            .padding(5)
                                            .background(Color("button2-color"))
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                    Button(action: {reject(notify: notif)}){
                                        Text("Reject")
                                            .padding(5)
                                            .background(Color("button2-color"))
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                    
                                }
                                .padding([.vertical])
                            }.padding(.horizontal)
                        Divider()
                        }.background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                    }
                }
            }
            .refreshable {
                // scroll to refresh
                isFetching = true
                notifys = []
                await fetchNotfications()
            }
            .task{
                // fetching for one time
                guard notifys.isEmpty else{return}
                await fetchNotfications()
                
                
            }
        }
        
    }
    func reject(notify : Notification){
        Task{
            
            
            try await Firestore.firestore().collection("groups").document(notify.groupID).updateData([
                    "requests": FieldValue.arrayRemove([userUID])
                ])
            try await Firestore.firestore().collection("notification").document(notify.id).updateData(["dismissStatus" : true])
            await fetchNotfications()
        }
    }
func fetchNotfications()async{
        do{
            var query: Query!
            //implementing pagination here
//            if let paginationDoc{
////                query = Firestore.firestore().collection("Group_Audios")
////                    .whereField("groupID",isEqualTo: group.id)
////                    .order(by: "publishedDate", descending: false)
////                    .start(afterDocument:paginationDoc)
////                    .limit(to: 20)
//            }else{
                query = Firestore.firestore().collection("notification")
                    .whereField("toUserID",isEqualTo: userUID)
                    .whereField("dismissStatus",isEqualTo: false)
//            }
           
            let docs = try await query.getDocuments()
            let fetchedPosts = docs.documents.compactMap{doc->Notification? in
                try? doc.data(as: Notification.self)
            }
            await MainActor.run(body: {
                notifys = []
                notifys.append(contentsOf: fetchedPosts)
//                posts = fetchedPosts
//                posts.wrappedValue = fetchedPosts
               // paginationDoc = docs.documents.last
                isFetching = false
            })
        }catch{
            print(error.localizedDescription)
        }
    }
}

#Preview {
    NotificationView()
}
