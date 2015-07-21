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
    let notificationRange: Double = 20
    
    
    func getAllSightings(block: ([PFObject]?) -> Void ) {
        var query = PFQuery(className: "Sighting")
        query.orderByDescending("dateSeen")
        
        query.findObjectsInBackgroundWithBlock { (result: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {   //Got sightings successfully
                
            } else {
                println("Error in getting sightings")
            }
            
            block(result as? [PFObject])
        }
    }
    

    func getRecentSightings(sightingsIntervalFromNow: NSTimeInterval, block: ([PFObject]?) -> Void ) {
        var query = PFQuery(className: "Sighting")
        var dateRangeForSightings = NSDate(timeInterval: -1 * sightingsIntervalFromNow, sinceDate: NSDate())
        query.whereKey("dateSeen", greaterThanOrEqualTo: dateRangeForSightings)
        query.orderByDescending("dateSeen")
        
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
        sighting["animalType"] = animalType.capitalizedString
        sighting["location"] = PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
        sighting["dateSeen"] = NSDate()
        sighting["notes"] = notes
        sighting["photo"] = imageFile
        
        Utils.sharedInstance.reverseGeocodePoint( CLLocation(latitude: location.latitude, longitude: location.longitude), block: { (address: String) -> Void in
            sighting["address"] = address
            sighting.saveInBackgroundWithBlock({ (success:Bool, error: NSError?) -> Void in
                println("Sighting has been saved")
            })
        })

    }
    
    func getNextClosestSighting(#sightings: [PFObject], userLocation: CLLocationCoordinate2D, currentCenterCoord: CLLocationCoordinate2D, block: (CLLocationCoordinate2D) -> Void) {

        var closest = userLocation
        closest = self.findClosestSighting(sightings, userLocation: userLocation, currentCenterCoord: currentCenterCoord)
        block(closest)
    }
    
    private func findClosestSighting(sightings: [PFObject], userLocation: CLLocationCoordinate2D, currentCenterCoord: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let minimumDistance = Utils.sharedInstance.dist(loc1: userLocation, loc2: currentCenterCoord)
        
        var frontRunnerIndex = -1
        var frontRunnerDistance = 10000000000.0
        for(var i = 0; i < sightings.count; i++) {
            let dist = Utils.sharedInstance.dist(loc1: userLocation, loc2: Utils.sharedInstance.PFGeoPointToCLLocationCoordinate2D(sightings[i]["location"] as! PFGeoPoint))
            if dist > minimumDistance + 0.00001 && dist < frontRunnerDistance { //+0.00001 solves for ~tie~ bugs
                frontRunnerIndex = i
                frontRunnerDistance = dist
            }
        }
        
        //If we are at the last sighting and should wrap around
        if frontRunnerIndex == -1 {
            return userLocation
        }

        return Utils.sharedInstance.PFGeoPointToCLLocationCoordinate2D(sightings[frontRunnerIndex]["location"] as! PFGeoPoint)
    }
    
//PUSH NOTIFICATIONS
    
    func sendNotificationToUsersNearLoc(location: CLLocation) {
        let params = NSMutableDictionary()
        params.setValue(PFGeoPoint(location: location), forKey: "location")
        
        println("here")

        PFCloud.callFunctionInBackground("sendSightingNotification", withParameters: params as [NSObject : AnyObject]) { (result: AnyObject?, error: NSError?) -> Void in
            if error != nil {
                println("Error in sending push notification")
            } else {
                println("Successful push notification")
            }
        }
    }
    
   
    private func sendSightingNotification(location: PFGeoPoint) {

        println("In sighting notification")
        // Find devices associated with these users
        let pushQuery = PFInstallation.query()
        pushQuery?.whereKey("location", nearGeoPoint: location, withinMiles: notificationRange)
        
        // Send push notification to query
        let push = PFPush()
        push.setQuery(pushQuery) // Set our Installation query
        push.setMessage("Free hotdogs at the Parse concession stand!")
        push.sendPushInBackgroundWithBlock(nil)
    }
    
    
}