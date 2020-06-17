//
//  ActorsTableViewCell.swift
//  Watch Me
//
//  Created by bhuvan on 23/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit

class ActorTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var actorNameLabel: UILabel!
    @IBOutlet weak var characterNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.cropToCircle()
        profileImageView.image = #imageLiteral(resourceName: "PosterPlaceholder")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
