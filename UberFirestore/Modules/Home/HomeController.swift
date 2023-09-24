//
//  HomeController.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 15.09.2023.
//

import UIKit
import FirebaseAuth
import MapKit

private let reuseIdentifier = "LocationCell"
private let annotationIdentifier = "DriverAnnotation"

private enum ActionButtonConfiguration {
    case showMenu
    case dismissActionView
    
    init() {
        self = .showMenu
    }
}

class HomeController: UIViewController {
    
    //MARK: - Properties
    
    private var viewModel = HomeViewModel()
    
    private let LocationinputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let rideActionView = RideActionView()
    private let locationHandler = LocationHandler.shared
    private let tableView = UITableView()
    private let mapView = MKMapView()
    
    
    private var searchResults = [MKPlacemark]()
    
    private final let locationInputViewHeight: CGFloat = 200
    private final let rideActionViewHeight: CGFloat = 300

    private var actionButtonConfig = ActionButtonConfiguration()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "baseline_menu_black_36dp")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        signOut()
        checkIfUserIsLoggedIn()
        viewModel.enableLocationServices()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    //MARK: - API
    
    func checkIfUserIsLoggedIn() {
        if viewModel.isUserLoggedIn {
            configureUI()
            fetchUser()
            LocationHandler.shared.delegate = self
        } else {
            DispatchQueue.main.async {
                let controller = LoginController()
                controller.delegate = self
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            }
        }
    }
    
    func startTrip() {
        viewModel.startTrip {
            guard let trip = self.viewModel.trip else { return }
            
            self.viewModel.fetchUser(forUid: trip.passengerUid) { interlocutor in
                self.rideActionView.configure(viewModel: RideActionViewModel(user: self.viewModel.user, interlocutor: interlocutor, config: .tripInProgress))
            }
            
            self.removeAnnotationsAndOverlays()
            self.mapView.addAnnotationAndSelect(forcoordinate: trip.destinationCoordinates)
            self.mapView.setCustomRegion(withType: .destination, withCoordinates: trip.destinationCoordinates)
            
            let placemark = MKPlacemark(coordinate: trip.destinationCoordinates)
            let mapItem = MKMapItem(placemark: placemark)
            
            self.viewModel.generatePolyline(toDestination: mapItem) { polyline in
                self.mapView.addOverlay(polyline)
                self.mapView.zoomToFit(annotations: self.mapView.annotations)
            }
        }
    }
    
    func fetchUser() {
        viewModel.fetchUser {
            self.locationInputView.user = self.viewModel.user
            if self.viewModel.user?.accountType == .passenger {
                self.fetchDrivers()
                self.configureLocationInputActivationView()
                self.observeCurrentTrip()
            } else {
                self.observeTrips()
            }
        }
    }
    
    func fetchDrivers() {
        viewModel.fetchDrivers { driver in
            guard let coordinate = driver.location?.coordinate else { return }
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            
            var driverIsVisible: Bool {
                return self.mapView.annotations.contains { anno in
                    guard let driverAnno = anno as? DriverAnnotation else { return false }
                    if driverAnno.uid == driver.uid {
                        driverAnno.updateAnnotationPosition(withCoordinate: coordinate)
                        return true
                    }
                    return false
                }
            }
            
            if !driverIsVisible {
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    func observeTrips() {
        guard let driver = viewModel.user else { return }
        viewModel.observeTrips(forDriver: driver) {
            if self.viewModel.trip?.state == .requested {
                guard let trip = self.viewModel.trip else { return }
                let controller = PickupController()
                controller.delegate = self
                controller.viewModel = PickupViewModel(trip: trip)
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            }
        }
    }
    
    func observeCurrentTrip() {
        viewModel.observeCurrentTrip {
            guard let trip = self.viewModel.trip else { return }
            guard let state = trip.state else { return }
            guard let driverUid = self.viewModel.trip?.driverUid else { return }

            
            switch state {
            case .requested:
                break
            case .accepted:
                self.shouldPresentLoadingView(false)
                self.removeAnnotationsAndOverlays()
                self.mapView.zoomForActiveTrip(withDriverUid: driverUid, mapView: self.mapView)
                
                self.viewModel.fetchUser(forUid: driverUid) { driver in
                    self.rideActionView.configure(viewModel: RideActionViewModel(user: self.viewModel.user, interlocutor: driver, config: .tripAccepted))
                }
                self.animateRideActionView(shouldShow: true)
            case .driverArrived:
                self.viewModel.fetchUser(forUid: driverUid) { driver in
                    self.rideActionView.configure(viewModel: RideActionViewModel(user: self.viewModel.user, interlocutor: driver, config: .driverArrived))
                }
            case .inProgress:
                self.viewModel.fetchUser(forUid: driverUid) { driver in
                    self.rideActionView.configure(viewModel: RideActionViewModel(user: self.viewModel.user, interlocutor: driver, config: .tripInProgress))
                }
            case .arrivedAtDestination:
                self.viewModel.fetchUser(forUid: driverUid) { driver in
                    self.rideActionView.configure(viewModel: RideActionViewModel(user: self.viewModel.user, interlocutor: driver, config: .endTrip))
                }
            case .completed:
                self.viewModel.deleteTrip {
                    self.animateRideActionView(shouldShow: false)
                    self.mapView.centerMapOnUserLocation()
                    self.configureActionButton(config: .showMenu)
                    self.actionButton.isHidden = false
                    self.showMessage(withTitle: "Trip Completed!", message: "We hope you enjoyed your trip")
                    
                    UIView.animate(withDuration: 0.3) {
                        self.LocationinputActivationView.alpha = 1
                    }
                }
            }
        }
    }
    
    func signOut() {
        viewModel.signOut()
    }
    
    //MARK: - Actions
    
    @objc func actionButtonPressed() {
        switch actionButtonConfig {
        case .showMenu:
            print("DEBUG: Handle Show menu..")
        case .dismissActionView:
            removeAnnotationsAndOverlays()
            mapView.showAnnotations(mapView.annotations, animated: true)
            
            UIView.animate(withDuration: 0.3) {
                self.LocationinputActivationView.alpha = 1
                self.configureActionButton(config: .showMenu)
                self.animateRideActionView(shouldShow: false)
            }
        }
    }
    
    @objc func didEnterRegion() {
        
    }
    
    //MARK: - Helpers
    
    func configureUI() {
        configureMapView()
        
        view.addSubview(actionButton)
        actionButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                            paddingTop: 16, paddingLeft: 20, width: 30, height: 30)
        
        configureTableView()
        configureRideActionView()
    }
    
    func configureLocationInputActivationView() {
        view.addSubview(LocationinputActivationView)
        LocationinputActivationView.centerX(inView: view)
        LocationinputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        LocationinputActivationView.anchor(top: actionButton.bottomAnchor, paddingTop: 32)
        LocationinputActivationView.alpha = 0
        LocationinputActivationView.delegate = self
        
        UIView.animate(withDuration: 1) {
            self.LocationinputActivationView.alpha = 1
        }
    }
    
    func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
    }
    
    func configureLocationInputView() {
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: locationInputViewHeight)
        locationInputView.delegate = self
        locationInputView.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            self.locationInputView.alpha = 1
            self.locationInputView.destinationLocationtextField.text = ""
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.tableView.frame.origin.y = self.locationInputViewHeight
            }
        }
    }
    
    func configureRideActionView() {
        view.addSubview(rideActionView)
        rideActionView.delegate = self
        rideActionView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: rideActionViewHeight)
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        
        
        view.addSubview(tableView)
    }
    
    func dismissLocationView(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
            self.locationInputView.removeFromSuperview()
        }, completion: completion)
    }
    
    func animateRideActionView(shouldShow: Bool) {
        let yOrigin = shouldShow ? self.view.frame.height - self.rideActionViewHeight : self.view.frame.height
        
        UIView.animate(withDuration: 0.3) {
            self.rideActionView.frame.origin.y = yOrigin
        }
    }
    
    func removeAnnotationsAndOverlays() {
        mapView.annotations.forEach { annotation in
            if let anno = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(anno)
            }
        }
        
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
    }
    
    
    
    fileprivate func configureActionButton(config: ActionButtonConfiguration) {
        switch config {
        case .showMenu:
            actionButton.setImage(UIImage(named: "baseline_menu_black_36dp")?.withRenderingMode(.alwaysOriginal), for: .normal)
            actionButtonConfig = .showMenu
        case .dismissActionView:
            actionButton.setImage(UIImage(named: "baseline_arrow_back_black_36dp")?.withRenderingMode(.alwaysOriginal), for: .normal)
            actionButtonConfig = .dismissActionView
        }
    }
}

//MARK: - AuthenticationDelegate

extension HomeController: AuthenticationDelegate {
    func authenticationDidComplete() {
        checkIfUserIsLoggedIn()
        self.dismiss(animated: true)
    }
}

//MARK: - RideActionViewDelegate

extension HomeController: RideActionViewDelegate {
    func pickupPassenger(_ view: RideActionView) {
        startTrip()
    }
    
    func cancelRide(_ view: RideActionView) {
        viewModel.deleteTrip() {
            UIView.animate(withDuration: 0.5) {
                self.LocationinputActivationView.alpha = 1
                self.actionButton.isHidden = false
                self.animateRideActionView(shouldShow: false)
                self.configureActionButton(config: .showMenu)
                self.configureLocationInputActivationView()
                self.removeAnnotationsAndOverlays()
                self.mapView.centerMapOnUserLocation()
            }
        }
    }
    
    func uploadTrip(_ view: RideActionView) {
        viewModel.uploadTrip(view: view) {
            self.shouldPresentLoadingView(true, message: "Finding you a ride...")
            self.animateRideActionView(shouldShow: false)
            self.actionButton.isHidden = true
        }
    }
    
    func dropOffPassenger(_ view: RideActionView) {
        guard let trip = viewModel.trip else { return}
        viewModel.updateTripState(trip: trip, state: .completed) {
            self.removeAnnotationsAndOverlays()
            self.mapView.centerMapOnUserLocation()
            self.animateRideActionView(shouldShow: false)
        }
    }
}

//MARK: - LocationInputActivationViewDelegate

extension HomeController: LocationInputActivationViewDelegate {
    func presentLocationInputView() {
        LocationinputActivationView.alpha = 0
        configureLocationInputView()
    }
}

//MARK: - LocationInputViewDelegate

extension HomeController: LocationInputViewDelegate {
    func executeSearch(query: String) {
        viewModel.searchLocationBy(naturalLanguageQuery: query, region: mapView.region) { results in
            self.searchResults = results
            self.tableView.reloadData()
        }
    }
    
    func dismissLocationInputView() {
        dismissLocationView { _ in
            UIView.animate(withDuration: 0.5) {
                self.LocationinputActivationView.alpha = 1
            }
        }
    }
}

//MARK: - PickUpControllerDelegate

extension HomeController: PickUpControllerDelegate {
    func didAcceptTrip(_ trip: Trip) {
        viewModel.trip = trip
        viewModel.trip?.state = .accepted
        
        self.mapView.addAnnotationAndSelect(forcoordinate: trip.pickupCoordinates)
        
        mapView.setCustomRegion(withType: .pickup, withCoordinates: trip.pickupCoordinates)
        
        let placemark = MKPlacemark(coordinate: trip.pickupCoordinates)
        let mapItem = MKMapItem(placemark: placemark)
        viewModel.generatePolyline(toDestination: mapItem) { polyline in
            self.mapView.addOverlay(polyline)
            self.mapView.zoomToFit(annotations: self.mapView.annotations)
            
            self.viewModel.observeTripCancelled(trip: trip) {
                self.animateRideActionView(shouldShow: false)
                self.removeAnnotationsAndOverlays()
                self.mapView.centerMapOnUserLocation()
                self.showMessage(withTitle: "Oops!", message: "The passenger has decided to cancel this ride. Press OK to continue.")
            }
            
            
            self.viewModel.fetchUser(forUid: trip.passengerUid) { passenger in
                self.rideActionView.configure(viewModel: RideActionViewModel(placemark: placemark, user: self.viewModel.user, interlocutor: passenger, config: .tripAccepted))
            }
            
            self.animateRideActionView(shouldShow: true)
//            NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterRegion), name: Notification.Name("NotificationIdentifier"), object: nil)
        }
        
        dismiss(animated: true)
    }
}

//MARK: - LocationHandlerDelegate

extension HomeController: LocationHandlerDelegate {
    func didStartMonitoringFor(region: CLRegion) {
        if region.identifier == AnnotationType.pickup.rawValue {
            print("DEBUG: Did start monitoring pick up region, \(region)")
        }
        if region.identifier == AnnotationType.destination.rawValue {
            print("DEBUG: Did start monitoring destination region, \(region)")
        }
    }
    
    func didEnterRegion(region: CLRegion) {
        guard let trip = viewModel.trip else { return }
        
        if region.identifier == AnnotationType.pickup.rawValue {
            viewModel.updateTripState(trip: trip, state: .driverArrived) {
                self.viewModel.fetchUser(forUid: trip.passengerUid) { interlocutor in
                    self.rideActionView.configure(viewModel: RideActionViewModel(user: self.viewModel.user, interlocutor: interlocutor, config: .pickupPassenger))
    //                NotificationCenter.default.removeObserver(self)
                }
            }
        }
        if region.identifier == AnnotationType.destination.rawValue {
            viewModel.updateTripState(trip: trip, state: .arrivedAtDestination) {
                self.viewModel.fetchUser(forUid: trip.passengerUid) { interlocutor in
                    self.rideActionView.configure(viewModel: RideActionViewModel(user: self.viewModel.user, interlocutor: interlocutor, config: .endTrip))
    //                NotificationCenter.default.removeObserver(self)
                }
            }
        }
        
        
    }
}


//MARK: - MKMapViewDelegate

extension HomeController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            view.image = UIImage(named: "chevron-sign-to-right")
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = viewModel.route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyline)
            lineRenderer.strokeColor = .mainBlueTint
            lineRenderer.lineWidth = 4
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let location = userLocation.location else { return }
        viewModel.updateDriverLocation(location: location) {
            
        }
    }
}

//MARK: - UITableViewDelegate/DataSource

extension HomeController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(section.magnitude)"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! LocationCell
        
        if indexPath.section == 1 {
            cell.configure(viewModel: LocationCellViewModel(placemark: searchResults[indexPath.row]))
            //            cell.viewModel = LocationCellViewModel(destination: searchResults[indexPath.row])
        } else {
            return UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlacemark = searchResults[indexPath.row]
        
        configureActionButton(config: .dismissActionView)
        
        let destination = MKMapItem(placemark: selectedPlacemark)
        viewModel.generatePolyline(toDestination: destination) { polyline in
            self.mapView.addOverlay(polyline)
        }
        
        dismissLocationView { _ in
            
            self.mapView.addAnnotationAndSelect(forcoordinate: selectedPlacemark.coordinate)
            
            let annotations = self.mapView.annotations.filter( { !$0.isKind(of: DriverAnnotation.self) } )
            self.mapView.zoomToFit(annotations: annotations)
            
            self.rideActionView.configure(viewModel: RideActionViewModel(placemark: selectedPlacemark, config: .requestRide))
            
            self.animateRideActionView(shouldShow: true)
        }
    }
}
