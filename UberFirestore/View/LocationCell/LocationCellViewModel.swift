//
//  LocationCellViewModel.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 18.09.2023.
//

import Foundation
import MapKit

class LocationCellViewModel {
    
    private var placemark: MKPlacemark?
    var type: LocationType?
    
    var titleText: String?
    
    var addressText: String?
    
    
    init(placemark: MKPlacemark? = nil, type: LocationType? = nil) {
        if let placemark = placemark {
            titleText = placemark.name
            addressText = placemark.address
        }
        self.type = type
    }
}
