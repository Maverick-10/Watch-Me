//
//  Alert+Comon.swift
//  Watch Me
//
//  Created by bhuvan on 24/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit

struct Alert {
    static let titleText = "Error"
    static let okayActionText = "OK"
    static let defaultErrorMessage = "Oops! something went wrong. Try again."
    
    static func show(on vc: UIViewController, message: String?) {
        let alertController = UIAlertController(title: titleText, message: message ?? defaultErrorMessage, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: okayActionText, style: .default, handler: nil)
        alertController.addAction(okayAction)
        vc.present(alertController, animated: true, completion: nil)
    }
}
