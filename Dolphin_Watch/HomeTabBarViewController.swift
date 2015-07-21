//
//  HomeTabBarViewController.swift
//  Dolphin_Watch
//
//  Created by Nathaniel Okun on 6/24/15.
//  Copyright (c) 2015 Nathaniel Okun. All rights reserved.
//

import UIKit

protocol HomeTabBarControllerDelegate {
    func sightingsLoaded(sightings: [PFObject])
}

class HomeTabBarViewController: UITabBarController {

    var sightings = [PFObject]()
    override func viewDidLoad() {
        super.viewDidLoad()
//        
//        ParseStore.sharedInstance.getAllSightings { (results: [PFObject]?) -> Void in
//            if let sightings = results {
//                self.sightings = sightings
//                println("Got Sightings in Tab View")
//                var nav = self.viewControllers![0] as! UINavigationController
//                var VC = nav.topViewController as! MapViewController
//                VC.sightings = sightings
//            }
//        }
        

        


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
