//
//  LoginViewModel.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 19.09.2023.
//

import Foundation
import FirebaseAuth

class LoginViewModel {
    
    let emailText = "Email"
    
    func login(withEmail email: String, password: String, completion: @escaping(Result<AuthDataResult, Error>) -> Void) {
        AuthService.shared.logUserIn(withEmail: email, password: password) { result, error in
            if let error {
                completion(.failure(error))
            } else if let result {
                completion(.success(result))
            }
        }
    }
}
