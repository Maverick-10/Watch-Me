//
//  LoginViewController.swift
//  Watch Me
//
//  Created by bhuvan on 21/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func loginUI(enabled: Bool) {
        emailTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        loginButton.isEnabled = enabled
        if enabled {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
    }

    // MARK: - Button Actions
    @IBAction func loginButtonPressed(_ sender: Any) {
        loginUI(enabled: false)
        WMClient.getRequestToken(completion: handleRequestTokenResponse(success:error:))
    }
    @IBAction func signUpButtonPressed(_ sender: Any) {
        UIApplication.shared.open(Endpoints.signUp.url, options: [:], completionHandler: nil)
    }
    
    func showLoginFailure(message: String) {
        let alertVC = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    func handleRequestTokenResponse(success: Bool, error: Error?) {
        if success {
            WMClient.login(username: self.emailTextField.text ?? "",
                             password: self.passwordTextField.text ?? "",
                             completion: self.handleLoginResponse(success:error:))
        } else {
            loginUI(enabled: true)
            showLoginFailure(message: error?.localizedDescription ?? "")
        }
    }
    
    func handleLoginResponse(success: Bool, error: Error?) {
        if success {
            WMClient.createSessionId(completion: handleSessionResponse(success:error:))
        } else {
            loginUI(enabled: true)
            showLoginFailure(message: error?.localizedDescription ?? "")
        }
    }
    
    func handleSessionResponse(success: Bool, error: Error?) {
        
        if success {
            self.performSegue(withIdentifier: "completeLogin", sender: nil)
        } else {
            showLoginFailure(message: error?.localizedDescription ?? "")
        }
    }
    
}
