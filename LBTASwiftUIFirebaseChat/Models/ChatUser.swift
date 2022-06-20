//
//  ChatUser.swift
//  LBTASwiftUIFirebaseChat
//
//  Created by Home on 6/20/22.
//

import Foundation

struct ChatUser: Identifiable{
    
    var id: String{uid}
    
    let uid, email, profileImageUrl: String
    
    init(data: [String: Any]){
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageUrl = data["imageProfileUrl"] as? String ?? ""
    }
}
