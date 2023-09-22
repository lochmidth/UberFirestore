//
//  RideActionView.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 20.09.2023.
//

import UIKit

protocol RideActionViewDelegate: AnyObject {
    func uploadTrip(_ view: RideActionView)
}

class RideActionView: UIView {
    
    //MARK: - Properties
    
    var buttonAction = ButtonAction()
    var viewModel: RideActionViewModel?
    weak var delegate: RideActionViewDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Loading.."
        label.textAlignment = .center
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "Loading.."
        label.textColor = .darkGray
        label.textAlignment = .center

        return label
    }()
    
    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        
        view.addSubview(infoViewLabel)
        infoViewLabel.centerX(inView: view)
        infoViewLabel.centerY(inView: view)
        
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Loading..."
        label.textAlignment = .center
        return label
    }()
    
    private let infoViewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        label.text = "?"
        return label
    }()
    
    lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle("Loading...", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addShadow()
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        
        addSubview(stack)
        stack.centerX(inView: self)
        stack.anchor(top: topAnchor, paddingTop: 12)
        
        addSubview(infoView)
        infoView.centerX(inView: self)
        infoView.anchor(top: stack.bottomAnchor, paddingTop: 16)
        infoView.setDimensions(height: 60, width: 60)
        infoView.layer.cornerRadius = 60 / 2
        
        addSubview(nameLabel)
        nameLabel.anchor(top: infoView.bottomAnchor, paddingTop: 8)
        nameLabel.centerX(inView: self)
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        addSubview(separatorView)
        separatorView.anchor(top: nameLabel.bottomAnchor, left: leftAnchor, right: rightAnchor,
                             paddingTop: 4, height: 0.75)
        
        addSubview(actionButton)
        actionButton.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor,
                            paddingLeft: 12, paddingBottom: 24, paddingRight: 12, height: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - API
    
    //MARK: - Actions
    
    @objc func actionButtonPressed() {
        guard let viewModel else { return }
        switch viewModel.buttonAction {
        case .requestRide:
            delegate?.uploadTrip(self)
        case .cancel:
            print("DEBUG: Handle cancel..")
        case .getDirections:
            print("DEBUG: Handle getDricetions..")
        case .pickup:
            print("DEBUG: Handle pickup..")
        case .dropOff:
            print("DEBUG: Handle cancel")
        }
    }
    
    //MARK: - Helpers
    
    func configure(viewModel: RideActionViewModel) {
        self.viewModel = viewModel
        
        actionButton.setTitle(viewModel.buttonText, for: .normal)
        actionButton.isEnabled = viewModel.activateButton ?? true
        titleLabel.text = viewModel.titleText
        addressLabel.text = viewModel.addressText
        infoViewLabel.text = viewModel.infoLabelText
        nameLabel.text = viewModel.nameText
    }
}
