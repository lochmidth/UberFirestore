//
//  User.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 15.09.2023.
//

import CoreLocation

enum AccountType: Int {
    case passenger
    case driver
}

struct User {
    let email: String
    let fullname: String
    var accountType: AccountType!
    var location: CLLocation?
    let uid: String
    var homeLocation: String?
    var workLocation: String?
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.email = dictionary["email"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.homeLocation = dictionary["homeLocation"] as? String ?? ""
        self.workLocation = dictionary["workLocation"] as? String ?? ""
        
        if let home = dictionary["homeLocation"] as? String {
            self.homeLocation = home
        }
        
        if let work = dictionary["workLocation"] as? String {
            self.workLocation = work
        }
        
        if let index = dictionary["accountType"] as? Int {
            self.accountType = AccountType(rawValue: index)
        }
    }
}

