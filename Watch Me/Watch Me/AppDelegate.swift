//
//  AppDelegate.swift
//  Watch Me
//
//  Created by bhuvan on 21/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize core data
        DataController.shared.load()
        
        return true
    }
    
}

