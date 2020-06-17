//
//  MainQueueUpdate.swift
//  Watch Me
//
//  Created by bhuvan on 21/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

func performUIUpdate(_ completion: @escaping () -> Void) {
    DispatchQueue.main.async {
        completion()
    }
}
