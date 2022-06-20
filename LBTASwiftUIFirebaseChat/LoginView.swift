//
//  ContentView.swift
//  LBTASwiftUIFirebaseChat
//
//  Created by Home on 6/9/22.
//
// Reference
// https://www.youtube.com/playlist?list=PL0dzCUj1L5JEN2aWYFCpqfTBeVHcGZjGw
//

import SwiftUI

struct LoginView: View {
    
    @State var loginStatusMessage = (isSuccess: false, message: "")
    @State var isLoginMode = false
    @State var email = ""
    @State var password = ""
    
    @State var shouldShowImagePicker = false
    @State var image: UIImage?
    
    var body: some View {
        NavigationView{
            ScrollView{
                
                VStack(spacing: 15) {
                    // create login/create account quick menu
                    Picker(selection: $isLoginMode, label: Text("Picker Here")) {
                        Text("Login")
                            .tag(true) // set isLoginMode == true
                        Text("Create Account")
                            .tag(false) // set isLogginMode == false
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if !isLoginMode
                    {
                        // create image login image with down state
                        Button {
                            shouldShowImagePicker
                                .toggle()
                        } label: {
                            // login image
                            VStack {
                                if let image = self.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 128, height: 128)
                                        .cornerRadius(64)
                                } else{
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .padding()
                                        .foregroundColor(Color(.label))
                                }
                            }
                            .overlay(RoundedRectangle(cornerRadius: 64)
                                        .stroke(Color.black, lineWidth: 3))
                        }
                    }
                    
                    // create e-mail and password window
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        SecureField("Password", text: $password)
                    }
                    .padding(10)
                    .background(Color.white)

                    // create confirmation button
                    Button {
                        handleAction()
                    } label: {
                        HStack{
                            Spacer() // fill windown horizontally
                            Text(isLoginMode ? "Log In" : "Create Account")
                                .foregroundColor(.white)
                                .padding(10)
                                .font(.system(size: 15, weight: .semibold))
                            Spacer()
                        }
                        .background(Color.blue)
                    }
                    
                    Text(self.loginStatusMessage.message)
                        .foregroundColor(self.loginStatusMessage.isSuccess ? .green : .red)
                    
                }
                .padding()
                
            }
            .navigationTitle(isLoginMode ? "Log In" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05))
                            .ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
            ImagePicker(image: $image)
        }
    }
    
    private func handleAction(){
        if isLoginMode{
            login()
        } else{
            createNewAccout()
        }
    }
    
    private func createNewAccout(){
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, error in
            if let err = error {
                self.loginStatusMessage.message = "Failed to create user: \(err)"
                self.loginStatusMessage.isSuccess = false
                return
            }
            
            // TODO: what does this operation: \( ?? )
            self.loginStatusMessage.message = "Succesfully created user: \(result?.user.uid ?? "")"
            self.loginStatusMessage.isSuccess = true
            
            self.persistImageToStorage()
        }
    }
    
    private func persistImageToStorage(){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else {return}
        
        ref.putData(imageData, metadata: nil) { meta, error in
            if let err = error {
                self.loginStatusMessage.message = "Failed to push image: \(err)"
                self.loginStatusMessage.isSuccess = false
                return
            }
            
            ref.downloadURL { url, error in
                if let err = error {
                    self.loginStatusMessage.message = "Failed to retrieve download URL: \(err)"
                    self.loginStatusMessage.isSuccess = false
                    return
                }
                
                self.loginStatusMessage.message = "Succesfully stored image with URL: \(url?.absoluteString ?? "")"
                self.loginStatusMessage.isSuccess = true
                
                guard let url = url else {return}
                
                self.storeUserInformation(imageProfileUrl: url)
            }
        }
    }
    
    private func storeUserInformation(imageProfileUrl: URL)
    {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        let userData = ["email" : self.email, "uid" : uid, "imageProfileUrl" : imageProfileUrl.absoluteString]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid)
            .setData(userData) { error in
                if let err = error {
                    self.loginStatusMessage.message = "Failed to store user data: \(err)"
                    self.loginStatusMessage.isSuccess = false
                    return
                }
                
                self.loginStatusMessage.message = "Succesfully stored user data: \(userData)"
                self.loginStatusMessage.isSuccess = true
            }
    }
    
    private func login(){
        
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            if let err = error {
                self.loginStatusMessage.message = "Failed to log in: \(err)"
                self.loginStatusMessage.isSuccess = false
            }
            
            self.loginStatusMessage.message = "Succesfully logged in: \(result?.user.uid ?? "")"
            self.loginStatusMessage.isSuccess = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

