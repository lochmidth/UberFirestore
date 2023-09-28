//
//  AuthService.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 15.09.2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import GeoFire

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
            
            guard let currentUid = result?.user.uid else { return }
            
            let values = ["email": credentials.email,
                          "fullname": credentials.fullname,
                          "accountType": credentials.accountType] as [String : Any]
            
            if credentials.accountType == 1 {
                
                let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
                let location = LocationHandler.shared.locationManager.location
                guard let location else { return }
                
                geofire.setLocation(location, forKey: currentUid) { error in
                    REF_USERS.child(currentUid).updateChildValues(values, withCompletionBlock: completion)
                }
            }
            
            REF_USERS.child(currentUid).updateChildValues(values, withCompletionBlock: completion)
        }
    }
}
