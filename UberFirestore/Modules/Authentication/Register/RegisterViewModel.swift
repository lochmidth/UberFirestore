//
//  RegisterViewModel.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 20.09.2023.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class RegisterViewModel {
    
    let titleText = "UBER"
    let emailText = "Email"
    let fullnameText = "Full Name"
    let passwordText = "password"
    let segmentItems = ["Rider", "Driver"]
    let buttonText = "Sign Up"
    
    func createUser(withCredentials credentials: AuthCredentials, completion: @escaping(Error?, DatabaseReference) -> Void) {
        AuthService.shared.createUser(withCredentials: credentials, completion: completion)
    }
    
}
