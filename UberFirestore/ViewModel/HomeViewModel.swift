//
//  HomeViewModel.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 19.09.2023.
//

import Foundation
import FirebaseAuth
import MapKit

class HomeViewModel {
    
    var user: User?
    
    var isUserLoggedIn: Bool {
        Auth.auth().currentUser?.uid != nil
    }
    
    func fetchUser(completion: @escaping () -> Void) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        UserService.shared.fetchUser(forUid: currentUid) { user in
            self.user = user
            completion()
        }
    }
    
    func fetchDrivers(at location: CLLocation, currentAnnotations: [MKAnnotation], completion: @escaping(DriverAnnotation) -> Void) {
        UserService.shared.fetchDrivers(location: location) { driver in
            guard let coordinate = driver.location?.coordinate else { return }
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            
            var driverIsVisible: Bool {
                return currentAnnotations.contains { annotation in
                    guard let driverAnno = annotation as? DriverAnnotation else { return false}
                    if driverAnno.uid == driver.uid {
                        driverAnno.updateAnnotationPosition(withCoordinate: coordinate)
                        return true
                    }
                    return false
                }
            }
            
            if !driverIsVisible {
                completion(annotation)
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print("DEBUG: Error while signing out, \(error.localizedDescription)")
        }
    }
    
    func searchBy(naturalLanguageQuery: String, region: MKCoordinateRegion, completion: @escaping([MKPlacemark]) -> Void) {
            let request = MKLocalSearch.Request()
            request.region = region
            request.naturalLanguageQuery = naturalLanguageQuery
            
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
}
