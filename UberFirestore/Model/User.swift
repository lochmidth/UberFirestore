//
//  User.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 15.09.2023.
//

import Foundation
import FirebaseAuth

struct User {
    let email: String
    let fullname: String
    let uid: String
    let accountType: Int
    
    var isCurrentUser: Bool { return Auth.auth().currentUser?.uid == uid }
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.email = dictionary["email"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.accountType = dictionary["accountType"] as? Int ?? 0
    }
}

