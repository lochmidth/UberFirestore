//
//  UserService.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 18.09.2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

struct UserService {
    static let shared = UserService()
    
    func fetchUser(completion: @escaping(User) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        REF_USERS.child(currentUid).observeSingleEvent(of: .value) { snapshot, _ in
            
            guard let dictionary = snapshot.value else { return }
            let user = User(uid: currentUid, dictionary: dictionary as! [String : Any])
            completion(user)
        }
    }
}
