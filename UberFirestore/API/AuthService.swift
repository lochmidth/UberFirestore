//
//  AuthService.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 15.09.2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

struct AuthCredentials {
    let email: String
    let password: String
    let fullname: String
    let accountType: Int
}

struct AuthService {
    static let shared = AuthService()
    
    func logUserIn(withEmail email: String, password: String, completion: @escaping(AuthDataResult?, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    func createUser(withCredentials credentials: AuthCredentials, completion: @escaping(Error?, DatabaseReference) -> Void) {
        Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { result, error in
            if let error {
                print("DEBUG: Error while creating user, \(error.localizedDescription)")
                return
            }
            
            guard let uid = result?.user.uid else { return }
            
            let values = ["email": credentials.email,
                          "fullname": credentials.fullname,
                          "accountType": credentials.accountType] as [String : Any]
            
            REF_USERS.child(uid).updateChildValues(values, withCompletionBlock: completion)
            }
        }
    }
