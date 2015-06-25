//
//  ParseStore.swift
//  Dolphin_Watch
//
//  Created by Nathaniel Okun on 6/6/15.
//  Copyright (c) 2015 Nathaniel Okun. All rights reserved.
//

import Foundation

class ParseStore {
    static let sharedInstance = ParseStore()
    
    func getAllSightings(block: ([PFObject]?) -> Void ) {
        var query = PFQuery(className: "Sighting")
        query.findObjectsInBackgroundWithBlock { (result: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {   //Got sightings successfully
                
            } else {
                println("Error in getting sightings")
            }
            
            block(result as? [PFObject])
        }
    }
    
    func saveSighting(#groupSize: Int, location: CLLocationCoordinate2D, animalType: String, notes: String, imageFile: PFFile) {
        let sighting = PFObject(className: "Sighting")
        sighting["groupSize"] = groupSize
        sighting["animalType"] = animalType
        let location = PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
        sighting["location"] = location
        sighting["dateSeen"] = NSDate()
        sighting["notes"] = notes
        sighting["photo"] = imageFile
        
        sighting.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            println("Sighting has been saved.")
        }
    }
    
    
    
}