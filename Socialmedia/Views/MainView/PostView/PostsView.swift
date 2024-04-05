//
//  PostView.swift
//  Overall_Backend
//
//  Created by user4 on 03/03/24.
//

import SwiftUI

struct PostsView: View {
    @State private var recentPosts: [Post] = []
    @State private var createNewPost: Bool = false
    @State private var isNotificationClicked: Bool = false
    var body: some View {
        NavigationStack{
            ReusablePostsView(posts: $recentPosts)            .hAlign(.center).vAlign(.center)
                .overlay(alignment: .bottomTrailing){
                    Button{
                        createNewPost.toggle()
                    }label: {
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.white)
                            .padding(13)
                            .background( Color("button-color"),in:Circle())
                    }
                    .padding(15)
                }
                .navigationTitle("Posts")
                .toolbar{
                                   ToolbarItem(placement: .topBarTrailing){
                                       NavigationLink(destination: NotificationView(), isActive: $isNotificationClicked) {
                                           Image(systemName: "bell.badge")
                                               .foregroundColor(.red)
                                       }
                                   }
                               }
        }
            .fullScreenCover(isPresented: $createNewPost){
                CreateNewPost{post in
                    // adding created posts at the top of the recent posts
                    recentPosts.insert(post, at: 0)
                }
            }
    }
}

#Preview {
    PostsView()
}


//import SwiftUI
//
//struct PostsView: View {
//    @State private var recentPosts: [Post] = []
//    @State private var createNewPost: Bool = false
//    @State private var isNotificationClicked: Bool = false
//    
//    var body: some View {
//        NavigationView {
//            ZStack {
//                // Your PostsView content
//                ReusablePostsView(posts: $recentPosts)
//                    .hAlign(.center)
//                    .vAlign(.center)
//                    .overlay(alignment: .bottomTrailing) {
//                        Button {
//                            createNewPost.toggle()
//                        } label: {
//                            Image(systemName: "plus")
//                                .font(.title3)
//                                .fontWeight(.semibold)
//                                .foregroundStyle(Color.white)
//                                .padding(13)
//                                .background(Color("button-color"), in: Circle())
//                        }
//                        .padding(15)
//                    }
//                    
//            }.navigationTitle("Posts")
//                .toolbar{
//                    ToolbarItem(placement: .topBarTrailing){
//                        NavigationLink(destination: NotificationView(), isActive: $isNotificationClicked) {
//                            Image(systemName: "bell.badge")
//                                .foregroundColor(.red)
//                        }
//                    }
//                }
//            
//           
//        }
//        .fullScreenCover(isPresented: $createNewPost) {
//            CreateNewPost { post in
//                // Adding created posts at the top of the recent posts
//                recentPosts.insert(post, at: 0)
//            }
//        }
//    }
//}
//
//#Preview {
//    PostsView()
//}


extension View{
    @available(iOS 14, *)
    func navigationBarColor(_ color: Color) -> some View {
        let uiColor = UIColor(color)
        UINavigationBar.appearance().barTintColor = uiColor

        return self
    }
}
