//
//  MarkFavorite.swift
//  Watch Me
//
//  Created by bhuvan on 23/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

struct MarkFavorite: Codable {
    let mediaType: String
    let mediaId: Int
    let favorite: Bool
    
    enum CodingKeys: String, CodingKey {
        case mediaType = "media_type"
        case mediaId = "media_id"
        case favorite = "favorite"
    }    
}
