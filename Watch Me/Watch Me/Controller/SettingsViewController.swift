//
//  SettingsViewController.swift
//  Watch Me
//
//  Created by bhuvan on 21/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let alertVC = UIAlertController(title: "Logout", message: "Do you want to log out?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            WMClient.logout {
                let loginVC = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
                self.navigationController?.viewControllers = [loginVC]
            }
        }
        let noAction = UIAlertAction(title: "No", style: .cancel) { (action) in
            self.tabBarController?.selectedIndex = 0
        }
        alertVC.addAction(yesAction)
        alertVC.addAction(noAction)
        present(alertVC, animated: true, completion: nil)
    }
}
