//
//  LocationHandler.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 18.09.2023.
//

import CoreLocation

protocol LocationHandlerDelegate: AnyObject {
    func didStartMonitoringFor(region: CLRegion)
    func didEnterRegion(region: CLRegion)
}

class LocationHandler: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationHandler()
    var locationManager: CLLocationManager!
    var location: CLLocation?
    
    weak var delegate: LocationHandlerDelegate?
    
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.distanceFilter = 250.0
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func enableLocationServices() {
        guard let locationManager = locationManager else { return }
        switch locationManager.authorizationStatus {
        case .notDetermined:
            print("DEBUG: Not determined..")
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            print("DEBUG: Auth always..")
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: Auth when in use..")
            locationManager.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        delegate?.didStartMonitoringFor(region: region)
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        delegate?.didEnterRegion(region: region)

//        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
    }
}
