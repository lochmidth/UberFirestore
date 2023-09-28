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
    var savedLocations = [MKPlacemark]()
    
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
    
    func fetchDrivers(completion: @escaping(User) -> Void) {
        guard let location = locationHandler.locationManager.location else { return }
        UserService.shared.fetchDrivers(location: location) { driver in
            completion(driver)
        }
    }
    
    func fetchUser(forUid uid: String, completion: @escaping(User) -> Void) {
        UserService.shared.fetchUser(forUid: uid) { user in
            completion(user)
        }
    }
    
    func startTrip(completion: @escaping() -> Void) {
        guard let trip else { return }
        TripService.shared.updateTripState(trip: trip, state: .inProgress) { _, _ in
            completion()
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
        guard let destinationCoordinates = view.viewModel?.destination?.coordinate else { return }
        TripService.shared.uploadTrip(pickupCoordinates, destinationCoordinates) { error, ref in
            if let error {
                print("DEBUG: Failed to upload trip with error: \(error.localizedDescription)")
                return
            }
            
            completion()
        }
    }
    
    func deleteTrip(completion: @escaping() -> Void ) {
        TripService.shared.deleteTrip { error, ref in
            if let error {
                print("DEBUG: Error while canceling the trip, \(error.localizedDescription)")
                return
            }
        }
        
        completion()
    }
    
    func observeTrips(forDriver driver: User, completion: @escaping() -> Void) {
        TripService.shared.observeTrips(forDriver: driver) { trip in
            self.trip = trip
            completion()
        }
    }
    
    func observeTripCancelled(trip: Trip, completion: @escaping() -> Void) {
        TripService.shared.observeTripCancelled(trip: trip) { snapshot in
            completion()
        }
    }
    
    func observeCurrentTrip(completion: @escaping() -> Void) {
        TripService.shared.observeCurrentTrip { trip in
            self.trip = trip
            completion()
        }
    }
    
    func updateDriverLocation(location: CLLocation, completion: @escaping() -> Void) {
        guard let user = user else { return }
        guard user.accountType == .driver else { return }
        
        UserService.shared.updateDriverLocation(location: location) { error in
            if let error {
                print("Error while updating the driver location, \(error.localizedDescription)")
                return
            }
            
            completion()
        }
    }
    
    func updateTripState(trip: Trip, state: TripState, completion: @escaping() -> Void) {
        TripService.shared.updateTripState(trip: trip, state: state) { error, ref in
            if let error {
                print("Error while updating the trip state, \(error.localizedDescription)")
                return
            }
            completion()
        }
    }
    
    func configureSavedUserLocations(completion: @escaping([MKPlacemark]) -> Void) {
        var placemarksToFetch = 0
        var fetchedPlacemarks = [MKPlacemark]()
        
        if let homeLocation = user?.homeLocation {
            placemarksToFetch += 1
            geocodeAddressString(address: homeLocation) { placemark in
                fetchedPlacemarks.append(placemark)
                placemarksToFetch -= 1
                if placemarksToFetch == 0 {
                    self.savedLocations.append(contentsOf: fetchedPlacemarks)
                    completion(fetchedPlacemarks)
                }
            }
        }
        if let workLocation = user?.workLocation {
            placemarksToFetch += 1
            geocodeAddressString(address: workLocation) { placemark in
                fetchedPlacemarks.append(placemark)
                placemarksToFetch -= 1
                if placemarksToFetch == 0 {
                    self.savedLocations.append(contentsOf: fetchedPlacemarks)
                    completion(fetchedPlacemarks)
                }
            }
        }
    }

    
    func geocodeAddressString(address: String, completion: @escaping(MKPlacemark) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error {
                print("DEBUG: Error wihle fetching saved addresses, \(error)")
                return
            }
            guard let clPlacemark = placemarks?.first else { return }
            let placemark = MKPlacemark(placemark: clPlacemark)
            completion(placemark)
        }
    }
}


