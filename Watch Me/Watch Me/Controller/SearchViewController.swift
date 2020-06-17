//
//  SearchViewController.swift
//  Watch Me
//
//  Created by bhuvan on 21/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit
import CoreData

class SearchViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    fileprivate var currentSearchTask: URLSessionDataTask?
    fileprivate var movies = [Movie]()
        
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension SearchViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonMovieTableViewCell") as! PersonMovieTableViewCell
        let movie = movies[indexPath.row]
        cell.movieNameLabel.text = movie.title
        cell.movieYearLabel.text = movie.releaseDate?.toYearString()
        if let imageData = movie.imageData {
            cell.movieImageView.image = UIImage(data: imageData)
        } else {
            WMClient.downloadPosterImage(path: movie.posterPath ?? "") { (imageData, error) in
                guard let data = imageData else {
                    return
                }
                // Save image data
                movie.imageData = data
                cell.movieImageView.image = UIImage(data: data)
                cell.setNeedsLayout()
            }
        }
        return cell
    }
}

// MARK: - Table view delegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movieDetailVC = storyboard?.instantiateViewController(identifier: "MovieDetailViewController") as! MovieDetailViewController
        movieDetailVC.movie = movies[indexPath.row]
        navigationController?.pushViewController(movieDetailVC, animated: true)
    }
}

// MARK: - Search bar delegate
extension SearchViewController: UISearchBarDelegate {
    
    func handleSearchResponse(response: [MovieModel]?, error: Error?) {
        if let response = response {
            movies.removeAll()
            response.forEach({ self.save(movie: $0)})
            tableView.reloadData()
        } else if let error = error {
            guard error.localizedDescription != "cancelled" else { return }
            Alert.show(on: self, message: error.localizedDescription)
        }
        
    }
    
    fileprivate func save(movie movieResponse: MovieModel) {
        let movie = Movie(context: DataController.shared.viewContext)
        movie.id = Int32(movieResponse.id ?? 0)
        movie.posterPath = movieResponse.posterPath
        movie.overview = movieResponse.overview
        movie.rating = movieResponse.voteAverage ?? 0
        movie.releaseDate = Date.date(fromString: movieResponse.releaseDate ?? "")
        movie.title = movieResponse.title
        movies.append(movie)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentSearchTask?.cancel()
        currentSearchTask = WMClient.search(query: searchText, completion: handleSearchResponse(response:error:))
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}



