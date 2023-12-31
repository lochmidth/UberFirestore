//
//  LoginController.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 13.09.2023.
//

import UIKit

protocol AuthenticationDelegate: AnyObject {
    func authenticationDidComplete()
}

class LoginController: UIViewController {
    
    //MARK: - Properties
    
    weak var delegate: AuthenticationDelegate?
    
    var viewModel = LoginViewModel()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.labelText
        label.font = UIFont(name: "Avenir-Light", size: 36)
        label.textColor = .init(white: 1, alpha: 0.8)
        return label
    }()
    
    private lazy var emailTextField = UITextField()
        .textField(withPlaceholder: viewModel.emailText, isSecureTextEntry: false)
    private lazy var passwordTextField = UITextField()
        .textField(withPlaceholder: viewModel.passwordText, isSecureTextEntry: true)
   
    private lazy var emailContainerView = UIView()
        .inputContainerView(image: UIImage(named: "ic_mail_outline_white_2x"), textField: emailTextField)
    private lazy var passwordContainerView = UIView()
        .inputContainerView(image: UIImage(named: "ic_lock_outline_white_2x"), textField: passwordTextField)
    
    private lazy var loginButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle(viewModel.buttonText, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    lazy var dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedTitle(firstPart: "Don't have an acoount?", secondPart: "Sign Up")
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
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
    
    @objc func handleShowSignUp() {
        let controller = RegisterController()
        controller.delegate = delegate
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleLogin() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        
        viewModel.login(withEmail: email, password: password) { result in
            switch result {
            case .success:
                self.delegate?.authenticationDidComplete()
                
            case .failure(let error):
                self.showMessage(withTitle: "Oops!", message: error.localizedDescription)
            }
        }

    }
    
    //MARK: - Helpers
    
    func configureUI() {
        
        view.backgroundColor = .backgroundColor
        
        view.addSubview(titleLabel)
        titleLabel.centerX(inView: view)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 0)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView,
                                                   passwordContainerView,
                                                   loginButton])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 16
        
        view.addSubview(stack)
        stack.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingRight: 16)
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.centerX(inView: view)
        dontHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 32)
        
        configureNavigationBar()
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
}
