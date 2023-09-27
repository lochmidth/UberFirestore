//
//  MenuHeaderViewModel.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 25.09.2023.
//

import Foundation

class MenuHeaderViewModel {
    
    var user: User
    
    var fullnameText: String {
        user.fullname
    }
    
    var emailText: String {
        user.email
    }
    
    var profileImageText: String {
        String(user.fullname.first ?? "X")
    }
    
    init(user: User) {
        self.user = user
    }
}


