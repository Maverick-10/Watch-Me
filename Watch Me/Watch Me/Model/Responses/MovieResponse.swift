//
//  MovieResponse.swift
//  Watch Me
//
//  Created by bhuvan on 21/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

class MovieResponse: Codable {
    let page: Int?
    let totalPages: Int?
    let totalResults: Int?
    let results: [MovieModel]?
    
    enum CodingKeys: String, CodingKey {
        case page
        case totalPages = "total_pages"
        case totalResults = "total_results"
        case results
    }
//
//    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        page = try container.decodeIfPresent(Int.self, forKey: .page) ?? 0
//        totalResults = try container.decodeIfPresent(Int.self, forKey: .totalResults) ?? 0
//        totalPages = try container.decodeIfPresent(Int.self, forKey: .totalPages) ?? 0
//        results = try container.decodeIfPresent([DiscoverMedia].self, forKey: .results) ?? [DiscoverMedia]()
//    }
}


class MovieModel: Codable {
    
    let id: Int?
    let posterPath: String?
    let title: String?
    let overview: String?
    let releaseDate: String?
    let voteAverage: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case posterPath = "poster_path"
        case title
        case overview
        case releaseDate = "release_date"
        case voteAverage = "vote_average"        
    }
//
//    required init(from decoder: Decoder) throws {
//
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
//        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath) ?? ""
//        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
//        overview = try container.decodeIfPresent(String.self, forKey: .overview) ?? ""
//        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate) ?? ""
//        voteCount = try container.decodeIfPresent(Int.self, forKey: .voteCount) ?? 0
//    }
}
