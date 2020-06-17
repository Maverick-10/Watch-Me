//
//  WMResponse.swift
//  Watch Me
//
//  Created by bhuvan on 21/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

struct WMResponse: Codable {
    
    let statusCode: Int
    let statusMessage: String
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case statusMessage = "status_message"
    }
}

extension WMResponse: LocalizedError {
    var errorDescription: String? {
        return statusMessage
    }
}
