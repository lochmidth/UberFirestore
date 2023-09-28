//
//  ContainerViewModel.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 25.09.2023.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class ContainerViewModel {
    
    var user: User?
    
    func fetchUser(completion: @escaping(User) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        UserService.shared.fetchUser(forUid: currentUid) { user in
            self.user = user
            completion(user)
        }
    }
    
    func signOut(completion: () -> Void) {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print("DEBUG: Error while signing out, \(error.localizedDescription)")
        }
        completion()
    }
    
    init(user: User? = nil) {
        self.user = user
    }
}
