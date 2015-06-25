//
//  Test.swift
//  Dolphin_Watch
//
//  Created by Nathaniel Okun on 6/5/15.
//  Copyright (c) 2015 Nathaniel Okun. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import MapKit

class LocationManager: NSObject, CLLocationManagerDelegate {
    //Create a sharedInstance
    static let sharedInstance = LocationManager()
    let locationUpdatedName = "LocationUpdatedNotification"
    
    let locationManager: CLLocationManager = CLLocationManager()
    
    override init() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        
        super.init()
        locationManager.delegate = self
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as! CLLocation
        NSNotificationCenter.defaultCenter().postNotificationName(locationUpdatedName, object: nil, userInfo: ["location":location])
    }
    
    /*
     * Subscribe the given observer to keep executing a given block everytime a location notification is posted.
     */
    func subscribeToLocationUpdates(observer: AnyObject, continueUpdating continueUpdate: Bool, withBlock block: (CLLocation) -> Void) {
        locationManager.startUpdatingLocation()
        NSNotificationCenter.defaultCenter().addObserverForName(locationUpdatedName, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification!) -> Void in
            
            //This code is called every time a notification is posted
            let location = notification.userInfo?["location"] as! CLLocation
            block(location)
            
            if !continueUpdate {
                self.locationManager.stopUpdatingLocation()
            }
        }
    }
}