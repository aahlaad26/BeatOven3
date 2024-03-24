//
//  GroupListView.swift
//  Socialmedia
//
//  Created by mathangy on 18/03/24.
//

import SwiftUI
//func openCustomURL() {
//        if let customURL = URL(string: "instagram://") {
//            if UIApplication.shared.canOpenURL(customURL) {
//                UIApplication.shared.open(customURL, options: [:], completionHandler: nil)
//            } else {
//                print("Cannot open URL: \(customURL)")
//            }
//        } else {
//            print("Invalid URL: facetime://")
//        }
//    }

func openInstagram() {
    let appURL = NSURL(string: "facetime://")!
    let webURL = NSURL(string: "https://facetime.com/")!
    
    let application = UIApplication.shared
    print("enter func")
    print(application.canOpenURL(appURL as URL))
    if application.canOpenURL(appURL as URL) {
        print("enter 1 if")
        print("set to true")
        application.open(appURL as URL)
    } else {
        // if Instagram app is not installed, open URL inside Safari
        print("enter else")
        application.open(webURL as URL)
    }
}

struct GroupListView: View {
    @State private var isPresented:Bool = false
    @EnvironmentObject private var model: Model
    
    var body: some View {
        NavigationStack {
            ScrollView{
                VStack{
                    
                    GroupList(groups: model.groups)
                    
                }
                .task{
                    do{
                        try await model.populateGroups()
                    }catch{
                        print(error)
                    }
                }.padding()
                    .sheet(isPresented: $isPresented){
                        AddNewGroupView()
                    }
                
                Button {
                    openInstagram()
                } label: {
                    Text("Facetime")
                }
                
            }
            .navigationTitle("Groups")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                Button("New Group"){
                    isPresented = true
                }
                
            }
        }
    }
    
    }


#Preview {
    GroupListView().environmentObject(Model())
}
