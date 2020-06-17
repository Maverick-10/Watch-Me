//
//  PostSession.swift
//  Watch Me
//
//  Created by bhuvan on 21/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

struct PostSession: Codable {
    let requestToken: String
    
    enum CodingKeys: String, CodingKey {
        case requestToken = "request_token"
    }
}
