//
//  ContainerController.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 25.09.2023.
//

import UIKit
import FirebaseAuth

class ContainerController: UIViewController {
    
    //MARK: - Properties
    
    var viewModel = ContainerViewModel()
    
    private var homeController: HomeController!
    private var menuController: MenuController!
    private var isExpanded = false
    private let blackView = UIView()
    
    private lazy var xOrigin = self.view.frame.width - 80
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfUserIsLoggedIn()
    }
    
    //MARK: - API
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            DispatchQueue.main.async {
                let controller = LoginController()
                controller.delegate = self
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            }
        } else {
            fetchCurrentUser { user in
                self.configure(viewModel: ContainerViewModel(user: user))
                self.configureUI()
            }
            
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return isExpanded
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    func fetchCurrentUser(completion: @escaping(User) -> Void) {
        viewModel.fetchUser { user in
            completion(user)
        }
    }
    //FIXME: - SignOut error, controllers get conflicted
    func signOut() {
        viewModel.signOut {
//            (UIApplication.shared.delegate as? SceneDelegate)?.window?.rootViewController = ContainerController()
            
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                        let sceneDelegate = scene.delegate as? SceneDelegate else {
                        return
                    }
            let controller = ContainerController()
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            controller.modalPresentationStyle = .fullScreen
            sceneDelegate.window?.rootViewController = controller
            
//            self.view.window!.rootViewController?.dismiss(animated: false) {
//                guard let controller = UIApplication.shared.keyWindow?.rootViewController as? ContainerController else { return }
//    //            let controller = ContainerController()
//    //            let nav = UINavigationController(rootViewController: controller)
//    //            nav.modalPresentationStyle = .fullScreen
//                controller.configure()
//    //            controller.modalPresentationStyle = .fullScreen
//            }
        }
    }
    
    //MARK: - Actions
    
    @objc func dismissMenu() {
        isExpanded = false
        animateMenu(shouldExpand: isExpanded)
    }
    
    //MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .backgroundColor
        
        configureHomeController()
        configureMenuController()
        configureBlackView()
    }
    
    func configure(viewModel: ContainerViewModel) {
        self.viewModel = viewModel
    }
    
    func configureHomeController() {
        homeController = HomeController()
        addChild(homeController)
        homeController.delegate = self
        homeController.didMove(toParent: self)
        view.addSubview(homeController.view)
    }
    
    func configureMenuController() {
        menuController = MenuController()
        menuController.delegate = self
        fetchCurrentUser { user in
            self.menuController.menuHeader.configure(viewModel: MenuHeaderViewModel(user: user))
        }
        addChild(menuController)
        menuController.didMove(toParent: self)
        view.insertSubview(menuController.view, at: 0)
    }
    
    func configureBlackView() {
        blackView.frame = CGRect(x: xOrigin, y: 0, width: 80, height: self.view.frame.height)
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blackView.alpha = 0
        view.addSubview(blackView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        blackView.addGestureRecognizer(tap)
    }
    
    func animateMenu(shouldExpand: Bool, completion: ((Bool) -> Void)? = nil) {
        
        if shouldExpand {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.homeController.view.frame.origin.x = self.xOrigin
                self.blackView.alpha = 1
            }
        } else {
            self.blackView.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeController.view.frame.origin.x = 0
            }, completion: completion)
        }
        animateStatusBar()
    }
    
    func animateStatusBar() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
}

//MARK: - HomeControllerDelegate

extension ContainerController: HomeControllerDelegate {
    func handleMenuToggle(_ controller: HomeController) {
        isExpanded.toggle()
        animateMenu(shouldExpand: isExpanded)
    }
}

//MARK: - MenuControllerDelegate

extension ContainerController: MenuControllerDelegate {
    func didSelect(option: MenuOptions) {
        isExpanded.toggle()
        animateMenu(shouldExpand: isExpanded) { _ in
            switch option {
            case .yourTrips:
                break
            case .settings:
                guard let user = self.viewModel.user else { return }
                let controller = SettingsController()
                controller.viewModel = SettingsViewModel(user: user)
                controller.delegate = self
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            case .logout:
                let alert = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
                
                alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
                    self.signOut()
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alert, animated: true)
            }
        }
    }
}

//MARK: - AuthenticationDelegate

extension ContainerController: AuthenticationDelegate {
    func authenticationDidComplete() {
        checkIfUserIsLoggedIn()
        self.dismiss(animated: true)
    }
}

//MARK: - SettingsControllerDelegate

extension ContainerController: SettingsControllerDelegate {
    func updateUser(_ controller: SettingsController) {
        guard let user = controller.viewModel?.user else { return }
        configure(viewModel: ContainerViewModel(user: user))
        homeController.viewModel.user = user
        homeController.reloadTableview()
    }
}
