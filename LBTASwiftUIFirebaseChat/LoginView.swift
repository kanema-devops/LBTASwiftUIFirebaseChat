//
//  ContentView.swift
//  LBTASwiftUIFirebaseChat
//
//  Created by Home on 6/9/22.
//

import SwiftUI

struct LoginView: View {
    
    @State var isLoginMode = false
    @State var email = ""
    @State var password = ""
    
    var body: some View {
        NavigationView{
            ScrollView{
                
                VStack(spacing: 15)
                {
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
                            
                        } label: {
                            // login image
                            Image(systemName: "person.fill")
                                .font(.system(size: 64))
                                .padding()
                        }
                    }
                    
                    // create e-mail and password window
                    Group
                    {
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
                }
                .padding()
                
            }
            .navigationTitle(isLoginMode ? "Log In" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05))
                            .ignoresSafeArea())
        }
    }
    
    private func handleAction(){
        if isLoginMode{
            print("Log in")
        } else{
            print("Create account")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
