//
//  PickupViewModel.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 21.09.2023.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class PickupViewModel {
    
    let trip: Trip

    func handleAcceptTrip(trip: Trip, completion: @escaping() -> Void) {
        TripService.shared.acceptTrip(trip: trip) { error, ref in
            if let error {
                print("DEBUG: Error while accepting trip, \(error.localizedDescription)")
                return
            }
            
            completion()
        }
    }
    
    func updateTripStateToDenied(completion: @escaping() -> Void ) {
        TripService.shared.updateTripState(trip: trip, state: .denied) { error, ref in
            if let error {
                print("DEBUG: Error while updating the trip state to denied, \(error.localizedDescription)")
                return
            }
            
            completion()
        }
    }
    
    init(trip: Trip) {
        self.trip = trip
    }
}
