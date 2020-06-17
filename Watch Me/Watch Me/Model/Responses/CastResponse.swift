//
//  CastResponse.swift
//  Watch Me
//
//  Created by bhuvan on 23/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

class CastResponse: Codable {
    let cast: [MovieCastResponse]?
}

class MovieCastResponse: Codable {
    let castId: Int32?
    let character: String?
    let creditId: String?
    let id: Int32?
    let order: Int32?
    let name: String?
    let profilePath: String?
    
    enum CodingKeys: String, CodingKey {
        case castId = "cast_id"
        case character
        case creditId = "credit_id"
        case id
        case name
        case order
        case profilePath = "profile_path"
    }
}
