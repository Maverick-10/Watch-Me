//
//  DiscoverViewController.swift
//  Watch Me
//
//  Created by bhuvan on 21/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit
import CoreData

class DiscoverViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // Properties
    fileprivate var media = [MovieModel]()
    fileprivate let dataController = DataController.shared
    fileprivate var fetchedResultsController: NSFetchedResultsController<Movie>!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
            
        setupFetchedResultsController()
        
        fetchMoviesFromServer()
        
        // Hide Collection View
        collectionView.isHidden = true
    }
    
    fileprivate func setupFetchedResultsController() {
        
        // Fetch saved pins
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
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
    
    fileprivate func setupCollectionViewLayout() {
        let numberOfColumns: CGFloat = 3.0
        let spacing: CGFloat = 1.5
        let dimension = (collectionView.frame.size.width/numberOfColumns) - ((numberOfColumns - 1) * spacing)
        flowLayout.minimumInteritemSpacing = spacing
        flowLayout.minimumLineSpacing = spacing
        flowLayout.itemSize = CGSize(width: dimension, height: dimension * 1.5)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupCollectionViewLayout()
        collectionView.isHidden = false
    }
    
    func fetchMoviesFromServer() {
        
        if segmentControl.selectedSegmentIndex == 0 {
            // Popular
            WMClient.getPopularMovie(completion: handleMovieResponse(movies:error:))
        } else {
            // Now Playing
            WMClient.getNowPlayingMovie(completion: handleMovieResponse(movies:error:))
        }
        collectionView.reloadData()
    }
    
    fileprivate func handleMovieResponse(movies: [MovieModel]?, error: Error?) {
        if let movies = movies {
            // Save movie detail in persistant
            movies.forEach({ self.save(movie: $0)})
        } else if let error = error {
            Alert.show(on: self, message: error.localizedDescription)
        }
    }
    
    
    func save(movie movieResponse: MovieModel) {
        
        // Check if movie already there
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        let predicate = NSPredicate(format: "id == %d", movieResponse.id ?? "")
        fetchRequest.predicate = predicate
        
        // Don't save if already saved
        guard let result = try? dataController.viewContext.fetch(fetchRequest), result.count == 0  else {
            return
        }
                
        let movie = Movie(context: self.dataController.viewContext)
        movie.id = Int32(movieResponse.id ?? 0)
        movie.posterPath = movieResponse.posterPath
        movie.overview = movieResponse.overview
        movie.rating = movieResponse.voteAverage ?? 0
        movie.releaseDate = Date.date(fromString: movieResponse.releaseDate ?? "")
        movie.title = movieResponse.title
        movie.isPopular = segmentControl.selectedSegmentIndex == 0
        movie.isNowPlaying = segmentControl.selectedSegmentIndex == 1
        
        dataController.save()
    }
    
    // MARK: Actions
    @IBAction func segmentControlPressed(_ sender: Any) {
        fetchMoviesFromServer()
    }
    
    
}

// MARK: Collection View Datasource
extension DiscoverViewController: UICollectionViewDataSource {
    
    fileprivate func getMovies() -> [Movie] {
        var movies = fetchedResultsController.fetchedObjects ?? [Movie]()
        if segmentControl.selectedSegmentIndex == 0 {
            movies = movies.filter({ $0.isPopular })
        } else {
            movies = movies.filter({ $0.isNowPlaying})
        }
        return movies
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getMovies().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as! MovieCollectionViewCell
        let movie = getMovies()[indexPath.row]
        
        cell.movieImageView.image = #imageLiteral(resourceName: "PosterPlaceholder")
        if let imageData = movie.imageData {
            cell.movieImageView?.image = UIImage(data: imageData)
        } else {
            WMClient.downloadPosterImage(path: movie.posterPath ?? "") { (imageData, error) in
                guard let data = imageData else {
                    return
                }
                // Save image data
                movie.imageData = data
                self.dataController.save()
                cell.movieImageView?.image = UIImage(data: data)
                cell.setNeedsLayout()
            }
        }
        return cell
    }
}

// MARK: Collection View Delegate
extension DiscoverViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = getMovies()[indexPath.row]
        let movieDetailVC = storyboard?.instantiateViewController(identifier: "MovieDetailViewController") as! MovieDetailViewController
        movieDetailVC.movie = movie
        navigationController?.pushViewController(movieDetailVC, animated: true)
    }
}



// MARK: - Fetch Result Controller Delegate
extension DiscoverViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        collectionView.reloadData()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
    }
}


