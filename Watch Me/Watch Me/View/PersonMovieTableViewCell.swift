//
//  PersonMovieTableViewCell.swift
//  Watch Me
//
//  Created by bhuvan on 23/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit

class PersonMovieTableViewCell: UITableViewCell {

    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var movieYearLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        movieImageView.image = #imageLiteral(resourceName: "PosterPlaceholder")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
