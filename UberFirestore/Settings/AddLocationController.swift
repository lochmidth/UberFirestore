//
//  AddLocationController.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 25.09.2023.
//

import UIKit
import MapKit

private let reuseIdentifier = "Cell"

protocol AddLocationControllerDelegate: AnyObject {
    func updateLocation(locationString: String, type: LocationType)
}

class AddLocationController: UITableViewController {
    
    //MARK: - Properties
    
    weak var delegate: AddLocationControllerDelegate?
    
    private let searchBar = UISearchBar()
    private let searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion()] {
        didSet { tableView.reloadData() }
    }
    private let type: LocationType
    private let location: CLLocation
    
    //MARK: - Lifecycle
    
    init(type: LocationType, location: CLLocation) {
        self.type = type
        self.location = location
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureSearchBar()
        configureSearchComleter()
        
        print("DEBUG: Type is \(type)")
    }

    //MARK: - API

    //MARK: - Actions

    //MARK: - Helpers
    
    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableHeaderView = UIView()
        tableView.rowHeight = 60
        
        tableView.addShadow()
    }
    
    func configureSearchBar() {
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar

    }
    
    func configureSearchComleter() {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        searchCompleter.region = region
        searchCompleter.delegate = self
    }
}

//MARK: - UITableViewDelegate/DataSource


extension AddLocationController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
        let result = searchResults[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = result.title
        content.secondaryText = result.subtitle
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = searchResults[indexPath.row]
        let locationString = result.title + " " + result.subtitle
        let trimmedLocationString = locationString.replacingOccurrences(of: ", United States", with: "")
        delegate?.updateLocation(locationString: trimmedLocationString, type: type)
    }
}

//MARK: - UISearchBarDelegate

extension AddLocationController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
}

//MARK: - MKLocalSearchCompleterDelegate


extension AddLocationController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        
        print("DEBUG: Search results: \(searchResults)")
        
        tableView.reloadData()
    }
}
