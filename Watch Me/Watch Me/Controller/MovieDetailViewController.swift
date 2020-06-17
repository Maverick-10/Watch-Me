//
//  MovieDetailViewController.swift
//  Watch Me
//
//  Created by bhuvan on 22/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit
import CoreData

class MovieDetailViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    fileprivate var favoriteButton: UIBarButtonItem!
    fileprivate var yearAndRuntimeLabel: UILabel!
    
    // MARK: - Properties
    internal var movie: Movie!
    fileprivate let dataController = DataController.shared
    fileprivate var fetchedResultsController: NSFetchedResultsController<Cast>!
    fileprivate var isFavorite: Bool {
        return movie.isFavourite
    }
        
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Navigation
        title = movie.title
        favoriteButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Favorite"), style: .done, target: self, action: #selector(favoriteButtonTapped(_:)))
        favoriteButton.tintColor = .red
        navigationItem.rightBarButtonItem = favoriteButton
        
        toggleBarButton(favoriteButton, enabled: isFavorite)
        
        setupFetchedResultsController()
                
        setupTableHeaderView()
        
        WMClient.getMovieDetail(movieId: Int(movie.id), completion: handleMovieDetailResponse(response:error:))
    }
    
    fileprivate func handleMovieDetailResponse(response: MovieDetailResponse?, error: Error?) {
        if let response = response {
            // Save movie runtime
            self.movie.runtime = response.runtime ?? 0
            dataController.save()
            // Save cast
            let movieCastResponse = response.credits?.cast ?? [MovieCastResponse]()
            for castResponse in movieCastResponse {
                save(cast: castResponse)
            }
            // Update label
            yearAndRuntimeLabel.text = getMovieDetailText()
        } else if let error = error {
            Alert.show(on: self, message: error.localizedDescription)
        }
    }
    
    func toggleBarButton(_ button: UIBarButtonItem, enabled: Bool) {
        if enabled {
            button.tintColor = UIColor.red
        } else {
            button.tintColor = UIColor.gray
        }
    }
    
    func save(cast castResponse: MovieCastResponse) {
        
        // Check if movie already there
        let fetchRequest: NSFetchRequest<Cast> = Cast.fetchRequest()
        let predicate = NSPredicate(format: "id == %d", castResponse.id ?? "")
        fetchRequest.predicate = predicate
        
        // Don't save if already saved
        guard let result = try?  dataController.viewContext.fetch(fetchRequest), result.count == 0  else {
            print("\(castResponse.name ?? "") is already in persistant")
            return
        }
        
        let cast = Cast(context: dataController.viewContext)
        cast.castId = castResponse.castId ?? 0
        cast.name = castResponse.name
        cast.character = castResponse.character
        cast.id = castResponse.id ?? 0
        cast.profilePath = castResponse.profilePath
        cast.creditId = castResponse.creditId
        cast.order = castResponse.order ?? 0
        cast.movie = self.movie
        dataController.save()
    }
            
    
    fileprivate func setupFetchedResultsController() {
        
        // Fetch saved pins
        let fetchRequest: NSFetchRequest<Cast> = Cast.fetchRequest()
        let predicate = NSPredicate(format: "movie == %@", movie)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
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
    
    /// Setup imageview in table header view.
    func setupTableHeaderView() {
        tableView.tableHeaderView = nil
        let headerImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height * 0.7))
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.backgroundColor = .black
        headerImageView.clipsToBounds = true
        headerImageView.image = #imageLiteral(resourceName: "PosterPlaceholder")
                
        // Setup gradient layer
        let height: CGFloat = headerImageView.frame.height * 0.5
        let yOrigin: CGFloat = headerImageView.frame.height - height
        let gradientViewFrame = CGRect(x: 0.0, y: yOrigin, width: headerImageView.frame.width, height: height)
        headerImageView.addGradient(frame: gradientViewFrame)
        
        // Add Label
        let labelHeight: CGFloat = 20.0
        let margin: CGFloat = 10.0
        let yOriginOfLabel: CGFloat = headerImageView.frame.height - labelHeight - margin
        let labelFrame = CGRect(x: margin, y: yOriginOfLabel, width: headerImageView.frame.width, height: labelHeight)
        yearAndRuntimeLabel = UILabel(frame: labelFrame)
        yearAndRuntimeLabel.text = getMovieDetailText()
        yearAndRuntimeLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .medium)
        yearAndRuntimeLabel.textColor = .white
        headerImageView.addSubview(yearAndRuntimeLabel)

        // Update image
        if let imageData = movie.imageData {
            headerImageView.image = UIImage(data: imageData)
        } else {
            WMClient.downloadPosterImage(path: movie.posterPath ?? "") { (data, error) in
                guard let imageData = data else { return }
                headerImageView.image = UIImage(data: imageData)
            }
        }
        // Add table header
        tableView.tableHeaderView = headerImageView
    }
    
    
    func getMovieDetailText() -> String {
        let year = movie.releaseDate?.toDateString() ?? ""
        let separator = "  •  "
        let duration =  "\(movie.runtime) min"
        return year + separator + duration
    }
    
    // MARK: - Actions
    @IBAction func favoriteButtonTapped(_ sender: UIBarButtonItem) {
        WMClient.markFavorite(movieId: Int(movie.id), favorite: !isFavorite, completion: handleFavoritesResponse(success:error:))
    }
    
    func handleFavoritesResponse(success: Bool, error: Error?) {
        if success {
            // Update value in persistant
            movie.isFavourite = !movie.isFavourite
            dataController.save()
            // Toggle button UI
            toggleBarButton(favoriteButton, enabled: isFavorite)
        } else if let error = error {
            Alert.show(on: self, message: error.localizedDescription)
        }
    }

}

// MARK: - Table view datasource
extension MovieDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActorTableViewCell") as! ActorTableViewCell
        let cast = fetchedResultsController.fetchedObjects![indexPath.row]
        cell.actorNameLabel?.text = cast.name ?? ""
        let characterText = cast.character!.isEmpty ? "" : "as \(cast.character!)"        
        cell.characterNameLabel?.text = characterText
        if let imageData = cast.imageData {
            cell.profileImageView.image = UIImage(data: imageData)
        } else {
            WMClient.downloadPosterImage(path: cast.profilePath ?? "") { (imageData, error) in
                guard let data = imageData else {
                    return
                }
                // Save image data
                cast.imageData = data
                self.dataController.save()
                cell.profileImageView.image = UIImage(data: data)
                cell.setNeedsLayout()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Cast"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

// MARK: - Table view delegate
extension MovieDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let personDetailVC = self.storyboard?.instantiateViewController(identifier: "PersonDetailViewController") as! PersonDetailViewController
        let personId = fetchedResultsController.fetchedObjects?[indexPath.row].id ?? 0
        personDetailVC.personId = Int(personId)
        navigationController?.pushViewController(personDetailVC, animated: true)
    }
}

// MARK: - Fetch Result Controller Delegate
extension MovieDetailViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        tableView.reloadData()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
    }
}



