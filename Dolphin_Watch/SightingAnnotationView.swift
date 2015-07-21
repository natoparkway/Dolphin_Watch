//
//  SightingAnnotationView.swift
//  Dolphin_Watch
//
//  Created by Nathaniel Okun on 6/21/15.
//  Copyright (c) 2015 Nathaniel Okun. All rights reserved.
//

import MapKit

protocol AnnotationDelegate {
    func photoLoaded(annotation: SightingAnnotationView)
}

class SightingAnnotationView: NSObject, MKAnnotation {
    let title: String
    let dateCreated: NSDate
    let coordinate: CLLocationCoordinate2D
    var image: UIImage
    var delegate: AnnotationDelegate?
    
    init(title: String, dateCreated: NSDate, coordinate: CLLocationCoordinate2D, photoFile: PFFile?) {
        self.title = title
        self.dateCreated = dateCreated
        self.coordinate = coordinate
        self.image = UIImage(named: "Bear_Icon")!   //Default image is a bear
        super.init()
        
        if photoFile != nil {
            photoFile?.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) -> Void in
                self.image = UIImage(data: data!)!
                self.delegate?.photoLoaded(self)
            })
        }
    }
    
    //Populates the subtitle of the annotation
    var subtitle: String {
        return Utils.sharedInstance.dateToString(dateCreated)
    }
}
