//
//  MenuHeader.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 25.09.2023.
//

import UIKit

class MenuHeader: UIView {
    
    //MARK: - Properties
    
    var viewModel: MenuHeaderViewModel?
    
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
        label.textColor = .white
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
        backgroundColor = .backgroundColor
        
        addSubview(infoView)
        infoView.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor,
                                paddingTop: 4, paddingLeft: 12, width: 64, height: 64)
        infoView.layer.cornerRadius = 64 / 2
        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel, emailLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 4
        
        addSubview(stack)
        stack.centerY(inView: infoView, leftAnchor: infoView.rightAnchor,
                      paddingLeft: 12)
    }
    
    func configure(viewModel: MenuHeaderViewModel) {
        self.viewModel = viewModel
        
        fullnameLabel.text = viewModel.fullnameText
        emailLabel.text = viewModel.emailText
        infoViewLabel.text = viewModel.profileImageText
    }
}
