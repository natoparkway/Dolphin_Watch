//
//  SightingsListViewController.swift
//  Dolphin_Watch
//
//  Created by Nathaniel Okun on 6/5/15.
//  Copyright (c) 2015 Nathaniel Okun. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class SightingsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var sightings = [PFObject]()
    var refreshControl = UIRefreshControl()
    var HUD: BFRadialWaveHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshControl.addTarget(self, action: "populateTable", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        HUD = BFRadialWaveHUD(view: view, fullScreen: true, circles: BFRadialWaveHUD_DefaultNumberOfCircles, circleColor: UIColor.grayColor(), mode: BFRadialWaveHUDMode.Default, strokeWidth: BFRadialWaveHUD_DefaultCircleStrokeWidth)
        populateTable()
    }
    
    //Get data and populate table
    func populateTable() {
        self.refreshControl.endRefreshing()
        self.HUD.show()
        ParseStore.sharedInstance.getAllSightings { (results: [PFObject]?) -> Void in
            if let sightings = results {
                self.sightings = sightings
                self.tableView.reloadData()
            } else {    //Something went wrong
                //DISPLAY ERROR MESSAGE
            }
            self.HUD.dismiss()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sightings.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("SightingCell", forIndexPath: indexPath) as! SightingCell
        cell.selectionStyle = .None
        cell.setFields(sightings[indexPath.row])
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
