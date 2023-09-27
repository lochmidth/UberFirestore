//
//  UserService.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 18.09.2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import GeoFire

struct UserService {
    static let shared = UserService()
    
    func fetchUser(forUid uid: String, completion: @escaping(User) -> Void) {
        REF_USERS.child(uid).observeSingleEvent(of: .value) { snapshot  in
            
            guard let dictionary = snapshot.value else { return }
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dictionary as! [String : Any])
            completion(user)
        }
    }
    
    func fetchDrivers(location: CLLocation, completion: @escaping(User) -> Void) {
        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
        
        REF_DRIVER_LOCATIONS.observe(.value) { snapshot in
            geofire.query(at: location, withRadius: 50).observe(.keyEntered, with: { uid, location in
                self.fetchUser(forUid: uid) { user in
                    var driver = user
                    driver.location = location
                    completion(driver)
                }
            })
        }
    }
    
    func updateDriverLocation(location: CLLocation, completion: @escaping(Error?) -> Void) {
        guard let driverUid = Auth.auth().currentUser?.uid else { return }
        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
        geofire.setLocation(location, forKey: driverUid) { error in
            completion(error)
        }
    }
    
    func saveLocation(LocationString: String, type: LocationType, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let key: String = type == .home ? "homeLocation" : "workLocation"
        REF_USERS.child(currentUid).child(key).setValue(LocationString, withCompletionBlock: completion)
    }
}
