//
//  MovieDetailResponse.swift
//  Watch Me
//
//  Created by bhuvan on 22/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

class MovieDetailResponse: Codable {
    let runtime: Int32?
    let credits: CastResponse?
    
    enum CodingKeys: String, CodingKey {
        case runtime
        case credits
    }
}


