//
//  AddNewGroupView.swift
//  Socialmedia
//
//  Created by mathangy on 18/03/24.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import PhotosUI

class UserIDs:ObservableObject{
    @Published var userIDs = [String]()
    func addUser(name: String) {
        userIDs.append(name)
    }
    func removeUser(name: String) {
        if let index = userIDs.firstIndex(of: name) {
            userIDs.remove(at: index)
        }
    }
}
struct AddNewGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var model: Model
    @State private var groupSubject: String = ""
    @State var showimagePicker:Bool = false
    @State var photoItem:PhotosPickerItem?
    @State var grpprofiledata: Data?
      private var isFormValid: Bool { !groupSubject.isEmpty }
    
    func saveGroup() async{
        do{
            print(ID.userIDs)
          let db = Firestore.firestore()
            var group = Groupped(subject: groupSubject)
            guard let imageData = grpprofiledata else{return}
            let Storageref = Storage.storage().reference().child("GrpProfile_Images").child(group.id)
            let _ = try await Storageref.putDataAsync(imageData)
            //step 3 download photourl
            
            let downloadurl = try await Storageref.downloadURL()
            group.grpProfileImage = downloadurl

//          db.collection("groups").addDocument(data: group.toDictionary()) { error in
//            if let error {
//              print(error.localizedDescription)
//            } else {
//              dismiss()
//            }
//          }
            let _ = try Firestore.firestore().collection("groups").document(group.documentId ?? group.id).setData(from: group, completion: {
                error in
                if error ==  nil{
                    //MARK: Print saved successfully
                    print("saved successfully")
                    dismiss()
                    
                }
            })
        }
        catch{
            print(error)
        }
      }
    
   
    @ObservedObject var ID = UserIDs()
    
    
    var body: some View {
        NavigationStack{
            VStack{
                ZStack{
                    if let grpprofiledata, let image = UIImage(data: grpprofiledata){
                        Image(uiImage: image).resizable()
                            .aspectRatio(contentMode: .fill)
                    }else{
                        Image("nullprof-img")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                }.frame(width: 85, height: 85)
                    .clipShape(Circle())
                    .contentShape(Circle())
                    .padding(.top,25)
                    .onTapGesture {
                        showimagePicker.toggle()
                    }
                Text("Group Profile")
                
                SearchUserGrpsView(ID: ID)
            }.toolbar{
                ToolbarItem(placement: .principal){
                    HStack{
                        TextField("Group Subject", text: $groupSubject)
                            .frame(width: 150)
                            .padding()
                    }

                    
                }
                ToolbarItem(placement: .navigationBarLeading){
                    Button("Cancel"){
                        dismiss()
                    }
                    
                }
                ToolbarItem(placement: .navigationBarTrailing){
                    Button("Create"){
                        Task{
                           let _ = try await saveGroup()
                        }
                        
                    }.disabled(!isFormValid)
                    
                }
            }
            .photosPicker(isPresented: $showimagePicker, selection:$photoItem )
            .onChange(of: photoItem){newValue in
                //MARK: Extracting UI Image from photoItem
                if let newValue{
                    Task{
                        do{
                            guard let imagedata = try await newValue.loadTransferable(type: Data.self)else{
                                return
                            }
                            //MARK: UI Must be updated on main thread
                            await MainActor.run(body:{ grpprofiledata = imagedata})
                        
                            
                        }catch{}
                    }
                }
            }
        }.padding()
        
    }
}


//#Preview {
//    NavigationStack {
//        AddNewGroupView()
//            .environmentObject(model)
//    }
//}


