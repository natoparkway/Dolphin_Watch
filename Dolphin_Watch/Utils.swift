//
//  utils.swift
//  Dolphin_Watch
//
//  Created by Nathaniel Okun on 7/18/15.
//  Copyright (c) 2015 Nathaniel Okun. All rights reserved.
//

import Foundation



class Utils {
    static let sharedInstance = Utils()
    static let sightingTimeRange: NSTimeInterval = 48 * 60 * 60    //48 hours (in seconds)
    static let currentInstallation = PFInstallation.currentInstallation()

    
    
    func dateToString(date: NSDate) -> String {
        var formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        
        return formatter.stringFromDate(date)
    }
    
    func PFGeoPointToCLLocationCoordinate2D(geoPoint: PFGeoPoint) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
    }
    
    func dist(#loc1: CLLocationCoordinate2D, loc2: CLLocationCoordinate2D) -> Double {
        let dx = loc1.latitude - loc2.latitude
        let dy = loc1.longitude - loc2.longitude
        return sqrt(dx * dx + dy * dy)
    }
    
    //In case of failure, return CLLocation coords as string
    func reverseGeocodePoint(location: CLLocation, block: (String) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks: [AnyObject]!, error: NSError!) -> Void in
            if let placemark = placemarks[0] as? CLPlacemark {
                block(placemark.name + ", " + placemark.locality)
            } else {
                block(location.description)
            }
        })
    
    }
    
    func timeToPresent(date: NSDate) -> String {
        return timeIntervalToString(NSDate().timeIntervalSinceDate(date))
    }
    
    private func timeIntervalToString(interval: NSTimeInterval) -> String {
        var time = NSInteger(interval)
        var output = ""
        
        if time > 24 * 60 * 60 {
            output = String(format: "%d days", time / (24 * 60 * 60))
        } else if time > 60 * 60 {
            output = String(format: "%d hours", time / (60 * 60))
        } else {
            output = String(format: "%d minutes", time / 60)
        }
        
        return output
    }
    
}