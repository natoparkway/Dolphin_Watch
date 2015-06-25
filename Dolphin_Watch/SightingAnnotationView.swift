//
//  SightingAnnotationView.swift
//  Dolphin_Watch
//
//  Created by Nathaniel Okun on 6/21/15.
//  Copyright (c) 2015 Nathaniel Okun. All rights reserved.
//

import MapKit

class SightingAnnotationView: NSObject, MKAnnotation {
    let title: String
    let notes: String
    let coordinate: CLLocationCoordinate2D
    var image: UIImage
    
    init(title: String, notes: String, coordinate: CLLocationCoordinate2D, photo: UIImage) {
        self.title = title
        self.notes = notes
        self.coordinate = coordinate
        self.image = photo

        
        super.init()
    }
    
    var subtitle: String {
        return notes
    }
}
