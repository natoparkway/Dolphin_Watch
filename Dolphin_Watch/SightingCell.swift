//
//  SightingCell.swift
//  Dolphin_Watch
//
//  Created by Nathaniel Okun on 6/24/15.
//  Copyright (c) 2015 Nathaniel Okun. All rights reserved.
//

import UIKit

class SightingCell: UITableViewCell {

    @IBOutlet weak var animalSpeciesLabel: UILabel!
    @IBOutlet weak var timeSeenLabel: UILabel!
    @IBOutlet weak var sightingDescriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var sightingImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setFields(sighting: PFObject) {
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
