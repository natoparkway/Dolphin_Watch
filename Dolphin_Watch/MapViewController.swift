//
//  MapViewController.swift
//  Dolphin_Watch
//
//  Created by Nathaniel Okun on 6/5/15.
//  Copyright (c) 2015 Nathaniel Okun. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit


class MapViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let zoomLong:CLLocationDistance = 1000
    let zoomLat:CLLocationDistance  = 1000
    var sightings = [PFObject]()
    var searchController:UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        setMapLocationToUser()
        
        ParseStore.sharedInstance.getAllSightings { (results: [PFObject]?) -> Void in
            if let sightings = results {
                self.sightings = sightings
                println("Got Sightings in Map View")
                self.putPinsOnMap()
            } else {    //Something went wrong
                //DISPLAY ERROR MESSAGE
                
            }
        }
        
        mapView.showsUserLocation = true
    }
    
    @IBAction func showSearchBar(sender: AnyObject) {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        presentViewController(searchController, animated: true, completion: nil)
    }
    
    //Called when user starts search
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
        
        let query = MKLocalSearchRequest()
        query.naturalLanguageQuery = searchBar.text
        
        let localSearch = MKLocalSearch(request: query)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            if localSearchResponse == nil {
                var alert = UIAlertView(title: nil, message: "Place not found", delegate: self, cancelButtonTitle: "Try again")
                alert.show()
                return
            }

            let location = CLLocationCoordinate2D(latitude: localSearchResponse.boundingRegion.center.latitude, longitude:     localSearchResponse.boundingRegion.center.longitude)
            let region = MKCoordinateRegionMakeWithDistance(location, self.zoomLat, self.zoomLong)
            self.mapView.setRegion(region, animated: false)
        }
    

        
    }
    
    //Refreshes screen and centers screen on user location.
    @IBAction func refreshButtonClicked(sender: AnyObject) {
        setMapLocationToUser()
    }
    /*
     * Sets the map's viewing region to that of the current user.
     */
    func setMapLocationToUser() {
        LocationManager.sharedInstance.subscribeToLocationUpdates(self, continueUpdating: false, withBlock: { (location: CLLocation) -> Void in
            let region = MKCoordinateRegionMakeWithDistance(location.coordinate, self.zoomLat, self.zoomLong)
            self.mapView.setRegion(region, animated: false)
        })
    }
    
    func putPinsOnMap() {
        for sighting in sightings {
            let geoPoint = sighting["location"] as! PFGeoPoint
            let sightingPoint = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
            var title = "Sighting"
            if let animalType = sighting["animalType"] as? String {
                title = animalType + " " + title
            }
            
            createAnnotation(sightingPoint, title: title, imageFile: sighting["photo"] as? PFFile)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     * Creates an annotation at the point of press when the user presses the map view.
     */
    @IBAction func mapLongPressed(sender: UILongPressGestureRecognizer) {
        performSegueWithIdentifier("CreateSighting", sender: sender)
        let touchPoint = sender.locationInView(mapView)
        let touchCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        createAnnotation(touchCoordinate, title: "Sighting", imageFile: nil)
    }
    
    /*
     * Creates an annotation at a given point with a given title and adds it the map view.
     */
    func createAnnotation(touchCoordinate: CLLocationCoordinate2D, title: String, imageFile: PFFile?) {
        var photo: UIImage!
        if imageFile == nil {
            photo = UIImage(named: "Bear_Icon")
        } else {
            //Here we should create the photo or something
            photo = UIImage(named: "Bear_Icon")
        }
        
        let annotation = SightingAnnotationView(title: title, notes: "testing", coordinate: touchCoordinate, photo: photo)
        mapView.addAnnotation(annotation)
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        //If the pin would be for the user location, return nil so that it shows default
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        if let annotation = annotation as? SightingAnnotationView {
            let identifier = "myAnnotationView"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView {
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
//FOR ADDING PHOTO: view.leftCalloutAccessoryView = UIImageView(frame: CGRect(x:0, y:0, width: 50, height:50))
            }

//FOR SETTING PHOTO: let imageView = view.leftCalloutAccessoryView as! UIImageView
            return view
         
            
        }
        return nil
    }
        


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let id = segue.identifier {
            if id == "CreateSighting" {
                let createSightingNav = segue.destinationViewController as! UINavigationController
                let createSightingVC = createSightingNav.topViewController as! CreateSightingViewController
                let locPoint = (sender as! UILongPressGestureRecognizer).locationInView(mapView)
                createSightingVC.location = mapView.convertPoint(locPoint, toCoordinateFromView: mapView)

            }
        }
    }

}
