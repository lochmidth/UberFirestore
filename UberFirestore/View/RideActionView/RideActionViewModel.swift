//
//  RideActionViewModel.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 20.09.2023.
//

import Foundation
import MapKit

class RideActionViewModel {
    
    var destination: MKPlacemark
    
    var titleText: String? {
        destination.name
    }
    
    var addressText: String? {
        destination.address
    }
    
    init(placemark: MKPlacemark) {
        self.destination = placemark
    }
}
