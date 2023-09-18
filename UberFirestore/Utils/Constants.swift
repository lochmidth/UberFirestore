//
//  Constants.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 15.09.2023.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

let STORAGE_REF = Storage.storage().reference()

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATIONS = DB_REF.child("driver-locations")
