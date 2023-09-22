//
//  RideActionViewModel.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 20.09.2023.
//

import Foundation
import MapKit

enum RideActionViewConfiguration {
    case requestRide
    case tripAccepted
    case pickupPassenger
    case tripInProgress
    case endTrip
    
    init() {
        self = .requestRide
    }
}

enum ButtonAction: CustomStringConvertible {
    case requestRide
    case cancel
    case getDirections
    case pickup
    case dropOff
    
    var description: String {
        switch self {
        case .requestRide:
            return "CONFIRM UBERX"
        case .cancel:
            return "CANCEL RIDE"
        case .getDirections:
            return "GET DIRECTIONS"
        case .pickup:
            return "PICKUP PASSENGER"
        case .dropOff:
            return "DROP OFF PASSENGER"
        }
    }
    
    init() {
        self = .requestRide
    }
}

class RideActionViewModel {
    
    var config: RideActionViewConfiguration
    var buttonAction = ButtonAction()
    var destination: MKPlacemark?
    var user: User?
    var driver: User?
    
    var titleText: String?
    var addressText: String?
    var buttonText: String?
    var activateButton: Bool?
    var nameText: String?
    var infoLabelText: String?
    
    
    init(placemark: MKPlacemark? = nil, user: User? = nil, interlocutor: User? = nil, config: RideActionViewConfiguration) {
        self.destination = placemark
        self.config = config
        self.user = user
        self.driver = interlocutor
        
        switch config {
        case .requestRide:
            titleText = destination?.name
            addressText = destination?.address
            infoLabelText = "X"
            nameText = "UBERX"
            buttonAction = .requestRide
            buttonText = buttonAction.description
        case .tripAccepted:
            guard let user else { return }
            
            if user.accountType == .driver {
                titleText = "En Route To Passenger"
                buttonAction = .getDirections
                buttonText = buttonAction.description
                activateButton = true
            } else {
                titleText = "Driver En Route"
                buttonAction = .cancel
                buttonText = buttonAction.description
                activateButton = true
            }
            guard let interlocutor else { return }
            infoLabelText = String(interlocutor.fullname.first ?? "X")
            nameText = interlocutor.fullname
        case .pickupPassenger:
            titleText = "Arrived at Passenger Location"
            buttonAction = .pickup
            buttonText = buttonAction.description
            activateButton = true
        case .tripInProgress:
            guard let user else { return }
            
            if user.accountType == .driver {
                buttonText = "TRIP IN PROGRESS"
                activateButton = false
            } else {
                buttonAction = .getDirections
                buttonText = buttonAction.description
                activateButton = true
            }
            
            titleText = "En Route To Destination"
        case .endTrip:
            guard let user else { return }
            
            if user.accountType == .driver {
                buttonText = "ARRIVED AT DESTINATION"
                activateButton = false
            } else {
                buttonAction = .dropOff
                buttonText = buttonAction.description
                activateButton = true
            }
        }
    }
}
