//
//  WMClient.swift
//  Watch Me
//
//  Created by bhuvan on 21/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation


class WMClient {
    
    // MARK: - GET
    @discardableResult
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                performUIUpdate {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let errorResponse = try decoder.decode(WMResponse.self, from: data)
                performUIUpdate {
                    completion(nil, errorResponse)
                }
            } catch {
                do {
                    let responseObject = try decoder.decode(ResponseType.self, from: data)
                    performUIUpdate {
                        completion(responseObject, nil)
                    }
                } catch  {
                    performUIUpdate {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        return task
    }
    
    
    // MARK: - POST
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void) {
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(body.self)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                performUIUpdate {
                    completion(nil, error)
                }
                return
            }
                        
            let decoder = JSONDecoder()
            do {
                let errorResponse = try decoder.decode(WMResponse.self, from: data)
                performUIUpdate {
                    completion(nil, errorResponse)
                }
            } catch {
                do {
                    let responseObject = try decoder.decode(ResponseType.self, from: data)
                    performUIUpdate {
                        completion(responseObject, nil)
                    }
                } catch  {
                    performUIUpdate {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
}


// MARK: - Login
extension WMClient {
    class func login(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        
        let body = LoginRequest(username: username, password: password, requestToken: SharedPreference.requestToken)
        taskForPOSTRequest(url: Endpoints.login.url, responseType: RequestTokenResponse.self, body: body) { (response, error) in
            if let response = response {
                SharedPreference.requestToken = response.requesToken
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    class func getRequestToken(completion: @escaping (Bool, Error?) -> Void) {
        
        taskForGETRequest(url: Endpoints.getRequestToken.url, response: RequestTokenResponse.self) { (response, error) in
            if let response = response {
                SharedPreference.requestToken = response.requesToken
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    class func createSessionId(completion: @escaping (Bool, Error?) -> Void) {
        
        let body = PostSession(requestToken: SharedPreference.requestToken)
        taskForPOSTRequest(url: Endpoints.createSessionId.url, responseType: SessionResponse.self, body: body) { (response, error) in
            if let response = response {
                SharedPreference.sessionId = response.sessionId
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
}

// MARK: - Discover
extension WMClient {
    class func discoverMedia(bySortType sortType: SortType, completion: @escaping ([MovieModel]?, Error?) -> Void) {
        
        taskForGETRequest(url: Endpoints.discover(sortBy: sortType).url, response: MovieResponse.self) { (response, error) in            
            if let response = response?.results {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
}


// MARK: - Get Favorites
extension WMClient {
    class func getFavorites(completion: @escaping ([MovieModel]?, Error?) -> Void) {
        
        taskForGETRequest(url: Endpoints.getFavorites.url, response: MovieResponse.self) { response, error in
            if let response = response?.results {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
}

// MARK: - Popular
extension WMClient {
    class func getPopularMovie(completion: @escaping ([MovieModel]?, Error?) -> Void) {
        
        taskForGETRequest(url: Endpoints.popular.url, response: MovieResponse.self) { (response, error) in
            if let response = response?.results {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
}

// MARK: - Now Playing
extension WMClient {
    class func getNowPlayingMovie(completion: @escaping ([MovieModel]?, Error?) -> Void) {
        
        taskForGETRequest(url: Endpoints.nowPlaying.url, response: MovieResponse.self) { (response, error) in
            if let response = response?.results {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
}

// MARK: - Search Movie
extension WMClient {
    class func search(query: String, completion: @escaping ([MovieModel]?, Error?) -> Void) -> URLSessionDataTask {
        let task = taskForGETRequest(url: Endpoints.search(query).url, response: MovieResponse.self) { response, error in
            if let response = response?.results {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
        return task
    }
}


// MARK: - Movie Detail
extension WMClient {
    class func getMovieDetail(movieId: Int, completion: @escaping (MovieDetailResponse?, Error?) -> Void) {
        
        taskForGETRequest(url: Endpoints.movieDetail(id: movieId).url, response: MovieDetailResponse.self) { (response, error) in
            if let response = response {
                
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
}

// MARK: - Person Detail
extension WMClient {
    class func getPersonDetail(personId: Int, completion: @escaping (PersonDetailResponse?, Error?) -> Void) {
        
        taskForGETRequest(url: Endpoints.personDetail(id: personId).url, response: PersonDetailResponse.self) { (response, error) in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
}



// MARK: - Download Image
extension WMClient {
    class func downloadPosterImage(path: String, completion: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.posterImageURL(path).url) { data, response, error in
            DispatchQueue.main.async {
                completion(data, error)
            }
        }
        task.resume()
    }
}


// MARK: - Add Favorites
extension WMClient {
    class func markFavorite(movieId: Int, favorite: Bool, completion: @escaping (Bool, Error?) -> Void) {
        let body = MarkFavorite(mediaType: "movie", mediaId: movieId, favorite: favorite)
        taskForPOSTRequest(url: Endpoints.markFavorite.url, responseType: WMResponse.self, body: body) { response, error in
            
            if let response = response {
                completion(response.statusCode == 1 || response.statusCode == 12 || response.statusCode == 13, nil)
            } else if let errorResponse = error as? WMResponse, errorResponse.statusCode == 1 || errorResponse
                .statusCode == 12 || errorResponse.statusCode == 13 {
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }

}

// MARK: - Logout
extension WMClient {
    class func logout(completion: @escaping () -> Void) {
        var request = URLRequest(url: Endpoints.logout.url)
        request.httpMethod = "DELETE"
        let body = LogoutRequest(sessionId: SharedPreference.sessionId)
        request.httpBody = try! JSONEncoder().encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            // Clear all saved data
            performUIUpdate {
                SharedPreference.clearDefaults()
                DataController.shared.clear()
                completion()
            }
        }
        task.resume()
    }        
}

