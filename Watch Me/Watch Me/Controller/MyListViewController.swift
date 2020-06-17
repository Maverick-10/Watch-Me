//
//  MyListViewController.swift
//  Watch Me
//
//  Created by bhuvan on 21/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit
import CoreData

class MyListViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    fileprivate let dataController = DataController.shared
    fileprivate var fetchedResultsController: NSFetchedResultsController<Movie>!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFetchedResultsController()
        
        WMClient.getFavorites(completion: handleMovieResponse(movies:error:))
    }
    
    fileprivate func handleMovieResponse(movies: [MovieModel]?, error: Error?) {
        if let movies = movies {
            // Save movie detail in persistant
            movies.forEach({ self.save(movie: $0)})
        } else if let error = error {
            Alert.show(on: self, message: error.localizedDescription)
        }
    }
    
    
    fileprivate func save(movie movieResponse: MovieModel) {
        
        // Check if movie already there
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        let predicate = NSPredicate(format: "id == %d", movieResponse.id ?? "")
        fetchRequest.predicate = predicate
        
        var movie: Movie!
        if let result = try? dataController.viewContext.fetch(fetchRequest), result.count > 0  {
            movie = result.first!
        } else {
            movie = Movie(context: self.dataController.viewContext)
        }
                
        movie.id = Int32(movieResponse.id ?? 0)
        movie.posterPath = movieResponse.posterPath
        movie.overview = movieResponse.overview
        movie.rating = movieResponse.voteAverage ?? 0
        movie.releaseDate = Date.date(fromString: movieResponse.releaseDate ?? "")
        movie.title = movieResponse.title
        movie.isFavourite = true
        
        dataController.save()
    }
    
    fileprivate func setupFetchedResultsController() {
        
        // Fetch saved pins
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        let predicate = NSPredicate(format: "isFavourite == YES")
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: dataController.viewContext,
                                                              sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
}

// MARK: - Table view delegate
extension MyListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonMovieTableViewCell") as! PersonMovieTableViewCell
        let movie = fetchedResultsController.object(at: indexPath)
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
                self.dataController.save()
                cell.movieImageView.image = UIImage(data: data)
                cell.setNeedsLayout()
            }
        }
        return cell
    }
}

// MARK: - Table view delegate
extension MyListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movieDetailVC = storyboard?.instantiateViewController(identifier: "MovieDetailViewController") as! MovieDetailViewController
        movieDetailVC.movie = fetchedResultsController.object(at: indexPath)
        navigationController?.pushViewController(movieDetailVC, animated: true)
    }
}

// MARK: - Fetch Result Controller Delegate
extension MyListViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        tableView.reloadData()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
    }
}


