//
//  PersonDetailViewController.swift
//  Watch Me
//
//  Created by bhuvan on 23/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit
import CoreData

class PersonDetailViewController: UIViewController {
    
    // MARK: - Outlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var placeOfBirthLabel: UILabel!
    
    // MARK: - Properties
    internal var personId: Int!
    fileprivate var dataController = DataController.shared
    fileprivate var person: Person?
    fileprivate var movies = [Movie]()
    
    

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WMClient.getPersonDetail(personId: personId) { (response, error) in
            if let response = response {
                self.movies = self.getSortedMovies(from: response)
                self.updateUI()
            } else if let error = error {                
                Alert.show(on: self, message: error.localizedDescription)
                
            }
        }
    }
    
    func getSortedMovies(from response: PersonDetailResponse) -> [Movie] {
        if let personMovies = self.getPerson(from: response).movies?.allObjects as? [Movie] {
            return personMovies.sorted(by: { (movie1, movie2) -> Bool in
                if let releaseDate1 = movie1.releaseDate, let releaseDate2 = movie2.releaseDate {
                    return releaseDate1 > releaseDate2
                }
                return false
            })
        }
        return [Movie]()
    }
    
    func updateUI() {

        tableView.reloadData()
        
        // Add blurred effet
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.systemChromeMaterialDark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backgroundImageView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundImageView.addSubview(blurEffectView)
        
        // Round Image
        personImageView.cropToCircle()

        func updateImageView(from imageData: Data) {
            backgroundImageView.image = UIImage(data: imageData)
            personImageView.image = UIImage(data: imageData)
        }
        
        if let imageData = person?.imageData {
            updateImageView(from: imageData)
        } else {
            WMClient.downloadPosterImage(path: person?.profilePath ?? "") { (data, error) in
                guard let imageData = data else {
                    return
                }
                updateImageView(from: imageData)
            }
        }
        
        // Labels
        nameLabel.text = person?.name ?? ""
        placeOfBirthLabel.text = person?.placeOfBirth ?? ""
    }
    
    fileprivate func getPerson(from personResponse: PersonDetailResponse) -> Person {
        
        // Fetch saved pins
        let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
        let predicate = NSPredicate(format: "id == %d", personResponse.id ?? 0)
        fetchRequest.predicate = predicate
        
        var person: Person!
        
        // Don't save if already saved
        if let result = try? dataController.viewContext.fetch(fetchRequest), result.count > 0 {
            person = result.first!
        } else {
            person = Person(context: dataController.viewContext)
        }
        
        person.id = personResponse.id ?? 0
        person.placeOfBirth = personResponse.placeOfBirth
        person.name = personResponse.name
        person.profilePath = personResponse.profilePath
        person.biography = personResponse.biography
        
        // Parse and save movies
        for movieResponse in personResponse.credits?.cast ?? [MovieModel]() {
            let movie = getMovie(from: movieResponse)
            movie.person = person
        }
        
        // Save locally
        self.person = person
        
        dataController.save()
        
        return person
    }
    
    func getMovie(from movieResponse: MovieModel) -> Movie {
        
        // Fetch saved pins
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        let predicate = NSPredicate(format: "id == %d", movieResponse.id ?? 0)
        fetchRequest.predicate = predicate
        
        var movie: Movie!
        
        if let result = try? dataController.viewContext.fetch(fetchRequest), result.count > 0 {
            movie = result.first!
        } else {
            movie = Movie(context: dataController.viewContext)
        }
        
        movie.id = Int32(movieResponse.id ?? 0)
        movie.posterPath = movieResponse.posterPath
        movie.overview = movieResponse.overview
        movie.rating = movieResponse.voteAverage ?? 0
        movie.releaseDate = Date.date(fromString: movieResponse.releaseDate ?? "")
        movie.title = movieResponse.title
        
        
        return movie
    }
}

// MARK: Table View Datasource
extension PersonDetailViewController: UITableViewDataSource {
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
                self.dataController.save()
                cell.movieImageView.image = UIImage(data: data)
                cell.setNeedsLayout()
            }
        }
        return cell
    }
}

// MARK: Table View Delegate
extension PersonDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movieDetailVC = storyboard?.instantiateViewController(identifier: "MovieDetailViewController") as! MovieDetailViewController
        movieDetailVC.movie = movies[indexPath.row]
        navigationController?.pushViewController(movieDetailVC, animated: true)
    }
}
