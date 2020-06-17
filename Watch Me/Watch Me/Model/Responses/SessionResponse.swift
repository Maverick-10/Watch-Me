//
//  SessionResponse.swift
//  Watch Me
//
//  Created by bhuvan on 21/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

struct SessionResponse: Codable {
    let success: Bool
    let sessionId: String
    
    enum CodingKeys: String, CodingKey {
        case success = "success"
        case sessionId = "session_id"
    }
}
