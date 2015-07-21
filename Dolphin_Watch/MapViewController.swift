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

let defaultZoomLong:CLLocationDistance = 1000
let defaultZoomLat:CLLocationDistance  = 1000

class MapViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate, SightingCreationDelegate, AnnotationDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var sightings = [PFObject]()
    var searchController:UISearchController!
    var userLocation: CLLocationCoordinate2D!
    var HUD: BFRadialWaveHUD!
    
    @IBOutlet weak var buttonSurroundView2: UIView!
    @IBOutlet weak var buttonSurroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        HUD = BFRadialWaveHUD(view: view, fullScreen: true, circles: BFRadialWaveHUD_DefaultNumberOfCircles, circleColor: UIColor.grayColor(), mode: BFRadialWaveHUDMode.Default, strokeWidth: BFRadialWaveHUD_DefaultCircleStrokeWidth)
        mapView.delegate = self
        setMapLocationToUser()
        getSightingsFromDBAndLoadMap()
        
        //Hacky way to make the buttons rounded instead of creating a custom class
        buttonSurroundView.layer.cornerRadius = buttonSurroundView2.frame.width / 2
        buttonSurroundView2.layer.cornerRadius = buttonSurroundView2.frame.width / 2
        
        mapView.showsUserLocation = true
    
    }
    
    func getSightingsFromDBAndLoadMap() {
        HUD.show()
        ParseStore.sharedInstance.getRecentSightings(Utils.sightingTimeRange) { (results: [PFObject]?) -> Void in
            if let sightings = results {
                self.sightings = sightings
                self.putPinsOnMap()
            } else {    //Something went wrong
                //DISPLAY ERROR MESSAGE
            }
            self.HUD.dismiss()
        }
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

            let location = CLLocationCoordinate2D(latitude: localSearchResponse.boundingRegion.center.latitude, longitude: localSearchResponse.boundingRegion.center.longitude)
            self.setMapLocationToPoint(location, zoomIn: true)
        }
    

        
    }
    
    //Refreshes screen and centers screen on user location.
    @IBAction func refreshButtonClicked(sender: AnyObject) {
        let annotationsToRemove = mapView.annotations.filter { $0 !== self.mapView.userLocation }
        mapView.removeAnnotations(annotationsToRemove)
        getSightingsFromDBAndLoadMap()
    }

    func setMapLocationToUser() {
        LocationManager.sharedInstance.subscribeToLocationUpdates(self, continueUpdating: false, withBlock: { (location: CLLocation) -> Void in
            self.userLocation = location.coordinate
            self.setMapLocationToPoint(location.coordinate, zoomIn: true)
        })
    }
    
    func setMapLocationToPoint(location: CLLocationCoordinate2D, zoomIn: Bool) {
        if zoomIn {
            let region = MKCoordinateRegionMakeWithDistance(location, defaultZoomLat, defaultZoomLong)
            mapView.setRegion(region, animated: false)
        } else {
            mapView.centerCoordinate = location
        }
    }
    
    func putPinsOnMap() {
        for sighting in sightings {
            let sightingPoint = Utils.sharedInstance.PFGeoPointToCLLocationCoordinate2D(sighting["location"] as! PFGeoPoint)
            let dateSeen = sighting["dateSeen"] as! NSDate
            var title = "Sighting"
            if let animalType = sighting["animalType"] as? String {
                title = animalType + " " + title
            }
            
            createAnnotation(sightingPoint, title: title, dateCreated: dateSeen,imageFile: sighting["photo"] as? PFFile)
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
                view.leftCalloutAccessoryView = UIImageView(frame: CGRect(x:0, y:0, width: 50, height:50))
            }
            
            var gr = UILongPressGestureRecognizer(target: self, action: "annotationLongPressed:")
            view.addGestureRecognizer(gr)
            
            (view.leftCalloutAccessoryView as! UIImageView).image = annotation.image
            return view
         
            
        }
        return nil
    }
    
    func annotationLongPressed(sender: UILongPressGestureRecognizer) {
        let locPoint = mapView.convertPoint(sender.locationInView(mapView), toCoordinateFromView: mapView)
        let region = MKCoordinateRegionMakeWithDistance(locPoint, defaultZoomLat, defaultZoomLong)
        
        var placemark = MKPlacemark(coordinate: locPoint, addressDictionary: nil)
        var mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Sighting Location!"
        mapItem.openInMapsWithLaunchOptions(nil)
    }
    

    
    //CreateSighting delegate method. Called when a sighting is created
    func sightingCreated(location: CLLocationCoordinate2D, animal: String, dateCreated: NSDate, imageFile: PFFile?) {
        createAnnotation(location, title: animal + " Sighting", dateCreated: dateCreated, imageFile: imageFile)
        ParseStore.sharedInstance.sendNotificationToUsersNearLoc(CLLocation(latitude: location.latitude, longitude: location.longitude))
    }
    
    /*
    * Creates an annotation at a given point with a given title and adds it the map view.
    */
    func createAnnotation(touchCoordinate: CLLocationCoordinate2D, title: String, dateCreated: NSDate, imageFile: PFFile?) {
        let annotation = SightingAnnotationView(title: title, dateCreated: dateCreated, coordinate: touchCoordinate, photoFile: imageFile)
        annotation.delegate = self
        mapView.addAnnotation(annotation)
    }
    
    func photoLoaded(annotation: SightingAnnotationView) {
        mapView.removeAnnotation(annotation)
        mapView.addAnnotation(annotation)
    }
    
    
    @IBAction func nextButtonPressed(sender: AnyObject) {
        ParseStore.sharedInstance.getNextClosestSighting(sightings: sightings, userLocation: self.userLocation, currentCenterCoord: self.mapView.centerCoordinate, block: { (closestCoord: CLLocationCoordinate2D) -> Void in
            self.setMapLocationToPoint(closestCoord, zoomIn: false)
        })
    }
    

    

    @IBAction func goToUserLocationPressed(sender: AnyObject) {
        setMapLocationToUser()
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
                createSightingVC.delegate = self
                createSightingVC.location = mapView.convertPoint(locPoint, toCoordinateFromView: mapView)

            }
        }

    }

}
