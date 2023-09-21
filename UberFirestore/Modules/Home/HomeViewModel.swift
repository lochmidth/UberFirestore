//
//  HomeViewModel.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 19.09.2023.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import MapKit

class HomeViewModel {
    
    var user: User?
    var trip: Trip?
    let locationHandler = LocationHandler.shared
    let localSearchManager = MKLocalSearchManager()
    var route: MKRoute?
    
    var isUserLoggedIn: Bool {
        Auth.auth().currentUser?.uid != nil
    }
    
    func enableLocationServices() {
        locationHandler.enableLocationServices()
    }
    
    func fetchUser(completion: @escaping () -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        UserService.shared.fetchUser(forUid: currentUid) { user in
            self.user = user
            completion()
        }
    }
    
    func fetchDrivers(currentAnnotations: [MKAnnotation], completion: @escaping(DriverAnnotation) -> Void) {
        guard let location = locationHandler.locationManager.location else { return }
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
    
    func searchLocationBy(naturalLanguageQuery: String, region: MKCoordinateRegion, completion: @escaping([MKPlacemark]) -> Void) {
        localSearchManager.searchBy(naturalLanguageQuery: naturalLanguageQuery, region: region, completion: completion)
    }
    
    func generatePolyline(toDestination destination: MKMapItem, completion: @escaping(MKPolyline) -> Void) {
        
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { response, error in
            guard let response else { return }
            self.route = response.routes[0]
            guard let polyline = self.route?.polyline else { return }
            completion(polyline)
        }
    }
    
    func uploadTrip(view: RideActionView, completion: @escaping() -> Void) {
        guard let pickupCoordinates = locationHandler.locationManager.location?.coordinate else { return }
        guard let destinationCoordinates = view.viewModel?.destination.coordinate else { return }
        TripService.shared.uploadTrip(pickupCoordinates, destinationCoordinates) { error, ref in
            if let error {
                print("DEBUG: Failed to upload trip with error: \(error.localizedDescription)")
                return
            }
            
            completion()
        }
    }
    
    func observeTrips(forDriver driver: User, completion: @escaping() -> Void) {
        TripService.shared.observeTrips(forDriver: driver) { trip in
            self.trip = trip
            completion()
        }
    }
    
    func observeCurrentTrip(completion: @escaping() -> Void) {
        TripService.shared.observeCurrentTrip { trip in
            self.trip = trip
            completion()
        }
    }
}


