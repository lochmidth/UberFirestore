//
//  MKLocalSearchManager.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 19.09.2023.
//

import Foundation
import MapKit

class MKLocalSearchManager {
    func searchBy(naturalLanguageQuery: String, region: MKCoordinateRegion, completion: @escaping([MKPlacemark]) -> Void) {
        let request = createRequest(naturalLanguageQuery: naturalLanguageQuery, region: region)
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response else { return }
            
            var results = [MKPlacemark]()
            
            response.mapItems.forEach { item in
                results.append(item.placemark)
            }
            
            completion(results)
        }
    }
    
    //MARK:- Helpers
    
    private func createRequest(naturalLanguageQuery: String, region: MKCoordinateRegion) -> MKLocalSearch.Request {
        let request = MKLocalSearch.Request()
        request.region = region
        request.naturalLanguageQuery = naturalLanguageQuery
        return request
    }
}
