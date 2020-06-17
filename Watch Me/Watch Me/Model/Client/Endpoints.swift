//
//  Endpoints.swift
//  Watch Me
//
//  Created by bhuvan on 21/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

enum SortType {
    case popularity
    case releaseDate
    
    var queryParam: String {
        switch self {
        case .popularity:
            return "sort_by=popularity.desc"
        case .releaseDate:
            return "sort_by=release_date.desc"
        }
    }
}

internal enum Endpoints {
    
    struct Auth {
        static var accountId = 0
    }


    fileprivate static let base = "https://api.themoviedb.org/3"
    fileprivate static let apiKey = "228d002c8abbb25d22b15f736b65ed37"
    fileprivate static let apiKeyParam = "?api_key=\(apiKey)"
    fileprivate static let languageParam = "&language=en-US"
    fileprivate static let regionParam = "&region=us"
    fileprivate static let pageParam = "&page=1"
    fileprivate static let movieCreditsParam = "&append_to_response=credits"
    fileprivate static let movieCreditsAndImagesParam = "&append_to_response=images%2Ccredits"
    
    case login
    case signUp
    case logout
    case getRequestToken
    case createSessionId
    case discover(sortBy: SortType)
    case posterImageURL(String)
    case search(String)
    case popular
    case nowPlaying
    case markWatchlist
    case markFavorite
    case movieDetail(id: Int)
    case personDetail(id: Int)
    case getFavorites    

    var stringValue: String {
        switch self {
        case .signUp: return "https://www.themoviedb.org/account/signup"
        case .getRequestToken: return Endpoints.base + "/authentication/token/new" + Endpoints.apiKeyParam
        case .createSessionId: return Endpoints.base + "/authentication/session/new" + Endpoints.apiKeyParam
        case .login: return Endpoints.base + "/authentication/token/validate_with_login" + Endpoints.apiKeyParam
        case .discover(let sortType): return Endpoints.base + "/discover/movie" + Endpoints.apiKeyParam + "&\(sortType.queryParam)" 
        case .posterImageURL(let posterPath): return "https://image.tmdb.org/t/p/w500" + posterPath
        case .logout: return Endpoints.base + "/authentication/session" + Endpoints.apiKeyParam
        case .search(let query): return Endpoints.base + "/search/movie" + Endpoints.apiKeyParam + "&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"            
        case .popular: return Endpoints.base + "/movie/popular" + Endpoints.apiKeyParam + Endpoints.languageParam + Endpoints.regionParam + Endpoints.pageParam
        case .nowPlaying: return Endpoints.base + "/movie/now_playing" + Endpoints.apiKeyParam + Endpoints.languageParam + Endpoints.regionParam + Endpoints.pageParam
        case .movieDetail(let movieId): return Endpoints.base + "/movie/\(movieId)" + Endpoints.apiKeyParam + Endpoints.languageParam + Endpoints.movieCreditsParam
        case .personDetail(let personId): return Endpoints.base + "/person/\(personId)" + Endpoints.apiKeyParam + Endpoints.languageParam + Endpoints.movieCreditsParam
        case .markWatchlist:
            return Endpoints.base + "/account/\(Auth.accountId)/watchlist" + Endpoints.apiKeyParam + "&session_id=\(SharedPreference.sessionId)"
        case .markFavorite:
            return Endpoints.base + "/account/\(Auth.accountId)/favorite" + Endpoints.apiKeyParam + "&session_id=\(SharedPreference.sessionId)"
        case .getFavorites: return Endpoints.base + "/account/\(Auth.accountId)/favorite/movies" + Endpoints.apiKeyParam + "&session_id=\(SharedPreference.sessionId)"
        }
    }

    var url: URL {
        return URL(string: stringValue)!
    }
}


extension URL {
    
    @discardableResult
    mutating func appendAPIKey() -> URL {
        self.appendQueryItem(name: "api_key", value: Endpoints.apiKey)
    }
}


extension URL {

    @discardableResult
    mutating func appendQueryItem(name: String, value: String?) -> URL {

        guard var urlComponents = URLComponents(string: absoluteString) else { return self }

        // Create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []

        // Create query item
        let queryItem = URLQueryItem(name: name, value: value)

        // Append the new query item in the existing query items array
        queryItems.append(queryItem)

        // Append updated query items array in the url component object
        urlComponents.queryItems = queryItems

        // Returns the url from new url components
        self = urlComponents.url!
        
        return self
    }
}
