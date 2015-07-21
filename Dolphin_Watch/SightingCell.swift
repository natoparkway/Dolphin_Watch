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
        addressLabel.preferredMaxLayoutWidth = addressLabel.frame.width
        sightingDescriptionLabel.preferredMaxLayoutWidth = sightingDescriptionLabel.frame.width
        addressLabel.preferredMaxLayoutWidth = addressLabel.frame.width
    }
    
    func setFields(sighting: PFObject) {
        animalSpeciesLabel.text = sighting["animalType"] as? String
        sightingDescriptionLabel.text = sighting["notes"] as? String
        addressLabel.text = sighting["address"] as? String
        timeSeenLabel.text = Utils.sharedInstance.timeToPresent(sighting["dateSeen"] as! NSDate)
        
        let photoFile = sighting["photo"] as? PFFile
        if photoFile != nil {
            photoFile?.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) -> Void in
                self.sightingImageView.image = UIImage(data: data!)!
            })
        } else {
            
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
