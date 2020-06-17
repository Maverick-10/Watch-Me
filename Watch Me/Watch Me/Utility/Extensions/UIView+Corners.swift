//
//  UIView+Corners.swift
//  Watch Me
//
//  Created by bhuvan on 23/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit

extension UIView {
    func cropToCircle() {
        layer.cornerRadius = bounds.height/2
        clipsToBounds = true
    }
}
