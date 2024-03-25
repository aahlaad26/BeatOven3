//
//  LoginView.swift
//  Overall_Backend
//
//  Created by user4 on 03/03/24.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct LoginView: View {
    
    //MARK: User details
    @State var emailID: String = ""
    @State var password:String = ""
    
    //MARK: View Properties
    @State var createAccount: Bool = false
    @State var showerror:Bool = false
    @State var errorMessage:String = ""
    @State var isloading:Bool = false
    @State var isPasswordVisible = false
    @State var isActive = false
    @AppStorage("user_profile_url") var profileURL:URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    @AppStorage("log_status") var logStatus:Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    Image("loginpage-img")
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.55)
                        .ignoresSafeArea()
                        .overlay(
                            Image("BeatOven")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 140, height: 140)
                                .offset(y: -130)
                        )
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 393, height: 475)
                            .background()
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .inset(by: 1.50)
                                    .stroke(Color(red: 0.37, green: 0.16, blue: 0.12), lineWidth: 1.50)
                                    .background(Color(""))
                            )
                            .offset(y: -30) // Adjust the offset as needed
                        
                        VStack(spacing: 20) {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 338, height: 64)
                                .background(Color(red: 0.9725490196078431, green: 0.93, blue: 0.90))
                                .cornerRadius(8)
                                .overlay(
                                    TextField(" Email", text: $emailID)
                                        .font(Font.custom("Catamaran", size: 18))
                                        .tracking(0.24)
                                        .lineSpacing(18)
                                        .foregroundColor(.black)
                                        .padding(.leading, 5)
                                )
                            
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 338, height: 64)
                                .background(Color(red: 0.9725490196078431, green: 0.93, blue: 0.90))

                                .cornerRadius(8)
                                .overlay(
                                    HStack {
                                        if isPasswordVisible {
                                            TextField(" Password", text: $password)
                                        } else {
                                            SecureField(" Password", text: $password)
                                        }
                                        
                                        Button(action: {
                                            isPasswordVisible.toggle()
                                        }) {
                                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                                .foregroundColor(.black)
                                                .padding(.trailing, 13)
                                        }
                                    }
                                        .font(Font.custom("Catamaran", size: 18))
                                        .tracking(0.24)
                                        .lineSpacing(18)
                                        .foregroundColor(.black)
                                        .padding(.leading, 5)
                                )
                        }
                        .offset(y: -150) // Adjust the offset to align with the bigger rectangle
                        
                        Text("Sign in")
                            .font(Font.custom("Catamaran", size: 28).weight(.bold))
                            .tracking(0.56)
                            .lineSpacing(41)
                            .foregroundColor(.white)
                            .offset(x: UIScreen.main.bounds.width / 2-330, y: UIScreen.main.bounds.height * 0.55 / 2 - 600) // Adjust the offset as needed
                        Text("Garnish your music with a dash of BeatOven magic")
                            .font(Font.custom("Catamaran", size: 18))
                            .lineSpacing(2)
                            .foregroundColor(.white)
                            .offset(x: UIScreen.main.bounds.width / 2-235, y: UIScreen.main.bounds.height * 0.55 / 2 - 550)
                        
                        Text("Forgot your password?")
                            .font(Font.custom("Catamaran", size: 14.5))
                            .tracking(0.26)
                            .lineSpacing(19.50)
                            .frame(maxWidth: .infinity, alignment: .trailing) // Align to the right
                            .padding(.top, -55)
                            .padding(.trailing, 16)
//                        NavigationLink(destination: MainView().navigationBarBackButtonHidden(true), isActive: $isActive) {
//                            EmptyView()
//                        }
                        Button(action: loginuser//{
//                            if !emailID.isEmpty,!password.isEmpty{
//                                Auth.auth().signIn(withEmail: emailID, password: password){
//                                    authResult, error in
//                                    if let error = error{
//                                        print("error in \(error.localizedDescription)")
//                                    }
//                                    else{
//                                        print("login sucessful")
//                                        isActive = true
//                                    }
//                                }
//
//                            }
//                        }
                        ) {
//                            Text("Sign In")
//                                .foregroundColor(.white)
//                                .padding()
//                                .background(Color("button2-color"))
//                                // Set your desired button color
//                                .cornerRadius(8)
                            
                            Text("Sign In")
                                .foregroundColor(.white)
                                .padding(20)
                                
                                .frame(maxWidth: .infinity) // Make the button fit the screen size horizontally
                                .background(Color("button2-color"))
                                .cornerRadius(20) // Increase this value for more rounded edges
                                .padding(.top, 2)
                        }.frame(width: 338, height: 64)
                           
                        .padding(.top, 75) // Add additional top padding for spacing
                         
                        

                         
                        Spacer()
                        // Add Spacer to push the HStack to the bottom
                        HStack{
                            Text("Dont have an account?")
                            Button("Register Now"){
                                createAccount.toggle()
                            }.fontWeight(.bold)
                                .foregroundColor(.black)
                                
                        }
                        .offset(y:100)
                    }
                    
                }
                .navigationBarHidden(true)
                .overlay(content:{
                    LoadingView(show: $isloading)
                })
                .fullScreenCover(isPresented: $createAccount){
                    RegisterView()
                }
//                VStack{
//
//                }.background(Color.white)
            }
        }
    }
    func loginuser(){
        isloading = true
        closekeyboard()
        Task{
            do{
                try await Auth.auth().signIn(withEmail: emailID, password: password)
                print("user found")
                logStatus = true
                try await fetchUser()
            }
            catch{
                await setError(error)
            }
        }
    }
    //MARK: IF USER FOUND THEN FETCHING USER DATA FROM FIRESTORE
    func fetchUser()async throws{
        guard let userID = Auth.auth().currentUser?.uid else{return}
        let user = try await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self)
        //MARK : UI UPDATING IN MAIN THREAD
        await MainActor.run(body: {
            //setting user defaults and changing app's auth status
            userUID = userID
            userNameStored = user.username
            profileURL = user.userprofileURL
            logStatus = true
        })
    }
    func resetpassword(){
        Task{
            do{
                try await Auth.auth().sendPasswordReset(withEmail: emailID)
                print("Link Sent")
            }
            catch{
                await setError(error)
            }
        }
    }
    //MARK: Disaplying error via alert
    func setError(_ error: Error)async{
        //MARK: UI MUST BE UPDATED ON MAINTHREAD
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showerror.toggle()
        })
        isloading = false
    }
}


#Preview {
    LoginView()
}
