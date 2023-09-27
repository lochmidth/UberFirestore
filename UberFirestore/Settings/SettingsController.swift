//
//  SettingsController.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 25.09.2023.
//

import UIKit

private let reuseIdentifier = "LocationCell"

protocol SettingsControllerDelegate: AnyObject {
    func updateUser(_ controller: SettingsController)
}

enum LocationType: Int, CaseIterable, CustomStringConvertible {
    case home
    case work
    
    var description: String {
        switch self {
        case .home:
            return "Home"
        case .work:
            return "Work"
        }
    }
    
    var subtitle: String {
        switch self {
        case .home:
            return "Add Home"
        case .work:
            return "Add Work"
        }
    }
}

class SettingsController: UITableViewController {
    
    //MARK: - Properties
    
    weak var delegate: SettingsControllerDelegate?
    
    var viewModel: SettingsViewModel?
    
    private lazy var infoHeader = UserInfoHeader()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    //MARK: - API
    
    //MARK: - Actions
    
    @objc func handleDismissal() {
        guard var userInfoUpdated = viewModel?.userInfoUpdated else { return }
        if userInfoUpdated {
            delegate?.updateUser(self)
            userInfoUpdated = false
        }
        self.dismiss(animated: true)
    }
    
    //MARK: -Helpers
    
    func configureUI() {
        tableView.rowHeight = 60
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.backgroundColor = .white
        tableView.isScrollEnabled = false
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = "Settings"
        navigationController?.navigationBar.barTintColor = .backgroundColor
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "baseline_clear_white_36pt_2x")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleDismissal))
        
        tableView.tableHeaderView = infoHeader
        tableView.tableFooterView = UIView()

        infoHeader.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        guard let user = self.viewModel?.user else { return }
        infoHeader.configure(viewModel: UserInfoHeaderViewModel(user: user))
    }
    
    func configure(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        self.tableView.reloadData()
    }
}

extension SettingsController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationType.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .backgroundColor
        
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 16)
        title.textColor = .white
        title.text = "Favorites"
        view.addSubview(title)
        title.centerY(inView: view, leftAnchor: view.leftAnchor, paddingLeft: 16)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        
        guard let type = LocationType(rawValue: indexPath.row) else { return cell }
        cell.configure(viewModel: LocationCellViewModel(type: type))
        cell.titleLabel.text = type.description
        cell.addressLabel.text = viewModel?.locationText(forType: type)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = LocationType(rawValue: indexPath.row) else { return }
        guard let location = LocationHandler.shared.locationManager.location else { return }
        let controller = AddLocationController(type: type, location: location)
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        present(nav, animated: true)
    }
}

//MARK: - AddLocationControllerDelegate

extension SettingsController: AddLocationControllerDelegate {
    func updateLocation(locationString: String, type: LocationType) {
        UserService.shared.saveLocation(LocationString: locationString, type: type) { error, ref in
            if let error {
                print("DEBUG: Error while saving the location to favorites, \(error.localizedDescription)")
                return
            }
            
            self.dismiss(animated: true)
            self.viewModel?.userInfoUpdated = true
            
            guard var user = self.viewModel?.user else { return }
            switch type {
            case .home:
                user.homeLocation = locationString
            case .work:
                user.workLocation = locationString
            }
        }
    }
}
