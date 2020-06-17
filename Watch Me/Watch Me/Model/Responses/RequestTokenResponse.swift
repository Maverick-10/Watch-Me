//
//  RequestTokenResponse.swift
//  Watch Me
//
//  Created by bhuvan on 21/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

struct RequestTokenResponse: Codable {
    let success: Bool
    let expiry: String
    let requesToken: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case expiry = "expires_at"
        case requesToken = "request_token"
    }
}

