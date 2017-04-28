//
//  LaunchViewController.swift
//  Photorama
//
//  Created by Matthew Olker on 4/28/17.
//  Copyright © 2017 Matthew Olker. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "launchPhoto"?:
            //gets an instance of PhotoStore
            let rootViewController = segue.destination as! UINavigationController
            let photosViewController = rootViewController.topViewController as! PhotosViewController
            photosViewController.store = PhotoStore()
            
            
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
    
}
