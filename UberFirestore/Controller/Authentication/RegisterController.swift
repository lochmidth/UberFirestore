//
//  RegisterController.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 14.09.2023.
//

import UIKit

class RegisterController: UIViewController {
    
    //MARK: - Properties
    
    weak var delegate: AuthenticationDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "UBER"
        label.font = UIFont(name: "Avenir-Light", size: 36)
        label.textColor = .init(white: 1, alpha: 0.8)
        return label
    }()
    
    private let emailTextField = UITextField()
        .textField(withPlaceholder: "Email", isSecureTextEntry: false)
    private let fullnameTextField = UITextField()
        .textField(withPlaceholder: "Full Name", isSecureTextEntry: false)
    private let passwordTextField = UITextField()
        .textField(withPlaceholder: "Password", isSecureTextEntry: true)
    private let accountTypeSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Rider", "Driver"])
        sc.backgroundColor = .backgroundColor
        sc.tintColor = UIColor(white: 1, alpha: 0.87)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    
    private lazy var emailContainerView = UIView()
        .inputContainerView(image: UIImage(named: "ic_mail_outline_white_2x"), textField: emailTextField)
    private lazy var fullnameContainerView = UIView()
        .inputContainerView(image: UIImage(named: "ic_person_outline_white_2x"), textField: fullnameTextField)
    private lazy var passwordContainerView = UIView()
        .inputContainerView(image: UIImage(named: "ic_lock_outline_white_2x"), textField: passwordTextField)
    private lazy var accountTypeContainerView = UIView()
        .inputContainerView(image: UIImage(named: "ic_account_box_white_2x"), segmentedControl: accountTypeSegmentedControl)
    
    private lazy var SignupButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    lazy var alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedTitle(firstPart: "Already have an acoount?", secondPart: "Log In")
        button.addTarget(self, action: #selector(handleBackToLogin), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - API
    
    //MARK: - Actions
    
    @objc func handleBackToLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleSignUp() {
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullname = fullnameTextField.text else { return }
        let accountType = accountTypeSegmentedControl.selectedSegmentIndex
        
        AuthService.shared.createUser(withCredentials:
                                        AuthCredentials(email: email, password: password, fullname: fullname, accountType: accountType)) { error, ref in
            
            self.delegate?.authenticationDidComplete()
        }
    }
    
    //MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .backgroundColor
        
        view.addSubview(titleLabel)
        titleLabel.centerX(inView: view)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 0)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView,
                                                   fullnameContainerView,
                                                   passwordContainerView,
                                                   accountTypeContainerView,
                                                   SignupButton])
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 24
        
        view.addSubview(stack)
        stack.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingRight: 16)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(inView: view)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 32)
        
        configureNavigationBar()
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
}
