//
//  UserInfoHeader.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 25.09.2023.
//

import Foundation

import UIKit

class UserInfoHeader: UIView {
    
    //MARK: - Properties
    
    var viewModel: UserInfoHeaderViewModel?
    
    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        
        view.addSubview(infoViewLabel)
        infoViewLabel.centerX(inView: view)
        infoViewLabel.centerY(inView: view)
        
        return view
    }()
    
    private let infoViewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        label.text = "?"
        return label
    }()
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "Full Name"
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.text = "name@email.com"
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
    
    func configureUI() {
        backgroundColor = .white
        
        addSubview(infoView)
        infoView.setDimensions(height: 64, width: 64)
        infoView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16, constant: 10)
        infoView.layer.cornerRadius = 64 / 2
        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel, emailLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 4
        
        addSubview(stack)
        stack.centerY(inView: infoView, leftAnchor: infoView.rightAnchor,
                      paddingLeft: 12)
    }
    
    func configure(viewModel: UserInfoHeaderViewModel) {
        self.viewModel = viewModel
        
        fullnameLabel.text = viewModel.fullnameText
        emailLabel.text = viewModel.emailText
        infoViewLabel.text = viewModel.profileImageText
    }
}
