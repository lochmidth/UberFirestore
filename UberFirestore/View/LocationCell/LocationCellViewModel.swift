//
//  LocationCellViewModel.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 18.09.2023.
//

import Foundation
import MapKit

class LocationCellViewModel {
    
    private var placemark: MKPlacemark
    
    var titleText: String? {
        placemark.name
    }
    
    var addressText: String? {
        placemark.address
    }
    
    init(placemark: MKPlacemark) {
        self.placemark = placemark
    }
}
