//
//  MainMessagesView.swift
//  LBTASwiftUIFirebaseChat
//
//  Created by Home on 6/13/22.
//

import SwiftUI
import SDWebImageSwiftUI

class MainMessagesViewModel: ObservableObject{
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var isUserCurrentlyLoggedOut = false
    
    init(){
        
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil 
        }
        
        fetchCurrentUser()
    }
    
    func fetchCurrentUser(){
        
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Invalid UID"
            return
        }
        
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let err = error{
                self.errorMessage = "Firebase firestore fetch error: \(err)"
                return
            }
            
            guard let data = snapshot?.data() else {
                self.errorMessage = "Firebase Firestore snapshot error"
                return}
            
            self.errorMessage = "Data: \(data.description)"
            
            self.chatUser = .init(data: data)
        }
    }
    
    func handleSignOut(){
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
}

struct MainMessagesView: View {
    
    @State var shouldShowLogOutOptions = false
    @ObservedObject private var vm = MainMessagesViewModel()
    @State var shouldShowNewMessageScreen = false
    @State var chatUser: ChatUser?
    @State var shouldNavigateToChatLogView = false
    
    var body: some View {
        
        NavigationView {
            VStack{
                customNavBar
                messagesView
                NavigationLink("", isActive: $shouldNavigateToChatLogView) {
                    ChatLogView(chatUser: self.chatUser)
                }
            }
            .overlay(newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
        }
    }
    
    private var messagesView: some View{
        ScrollView{
            ForEach(0..<10, id: \.self) { num in
                VStack{
                    NavigationLink {
                        Text("DESTINATION")
                    } label: {
                        HStack(spacing: 16){
                            Image(systemName: "person.fill")
                                .font(.system(size: 32))
                                .padding(8)
                                .overlay(RoundedRectangle(cornerRadius: 44)
                                .stroke(Color(.label), lineWidth: 1)
                            )
                            VStack(alignment: .leading){
                                Text("Username")
                                    .font(.system(size:16, weight: .bold))
                                
                                Text("Message sent to user")
                                    .font(.system(size:14))
                                    .foregroundColor(Color(.lightGray))
                            }
                            Spacer()
                            
                            Text("22d")
                                .font(.system(size:14, weight: .semibold))
                        }
                    }
                    Divider()
                        .padding(.vertical, 8)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 50)
        }
    }
    
    private var newMessageButton: some View{
        
        Button {
            shouldShowNewMessageScreen.toggle()
        } label: {
            HStack{
                Spacer()
                Text("+ New message")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
            .background(Color.blue)
            .cornerRadius(32)
            .padding(.horizontal)
            .shadow(radius: 15)
        }
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen, onDismiss: nil) {
            CreateNewMessageView(didSelectNewUser: {user in
                print(user.email)
                self.shouldNavigateToChatLogView.toggle()
                self.chatUser = user
            })
        }
    }
    
    struct ChatLogView: View {
        
        let chatUser: ChatUser?
        
        var body: some View{
            ScrollView{
                ForEach(0..<10){num in
                    Text("Fake Message")
                }
            }.navigationTitle(chatUser?.email ?? "Unknown User")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var customNavBar: some View{
        HStack{
             
            WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 50).stroke(Color(.label), lineWidth: 1))
                .shadow(radius: 5)
            
            VStack(alignment: .leading, spacing: 4){
                
                let userEmail = vm.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? ""
                
                Text(userEmail)
                    .font(.system(size: 24, weight: .bold))
                
                HStack{
                    Circle()
                        .frame(width: 14, height: 14)
                        .foregroundColor(Color.green)
                    
                    Text("online")
                        .font(.system(size: 14))
                        .foregroundColor(Color(.lightGray))
                }
            }
            Spacer()
            
            Button {
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            }
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
                .destructive(Text("Sign Out"), action: {
                    print("Handle signout")
                    vm.handleSignOut()
                }),
                .cancel()
            ])
        }
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil) {
            LoginView(didCompleteLoginProcess: {
                self.vm.isUserCurrentlyLoggedOut = false
                self.vm.fetchCurrentUser()
            })
        }
    }
}

struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
    }
}
