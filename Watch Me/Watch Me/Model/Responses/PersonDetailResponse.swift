//
//  PersonDetailResponse.swift
//  Watch Me
//
//  Created by bhuvan on 23/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

class PersonDetailResponse: Codable {
    let id: Int32?
    let name: String?
    let biography: String?
    let placeOfBirth: String?
    let profilePath: String?
    let credits: PersonMovieCredits?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case credits
        case biography
        case placeOfBirth = "place_of_birth"
        case profilePath = "profile_path"
    }
}


class PersonMovieCredits: Codable {
    let cast: [MovieModel]?
}

class PersonMovie: Codable {
    let id: String?
    let posterPath: String?
    let title: String?
    let releaseDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case posterPath = "poster_path"
        case title
        case releaseDate = "release_date"
    }
}
