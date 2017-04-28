//
//  PhotoInfoViewController.swift
//  Photorama
//
//  Created by Matthew Olker on 4/26/17.
//  Copyright © 2017 Matthew Olker. All rights reserved.
//  sets up the UI for viewing a single photo

import UIKit

class PhotoInfoViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    
    //holds the photo and sets the title
    var photo: Photo! {
        didSet {
            navigationItem.title = photo.title
        }
    }
    var store: PhotoStore!
    @IBOutlet var viewLabel: UILabel!
    
    //sets the image when the view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.fetchImage(for: photo) { (result) -> Void in
            switch result {
                case let .success(image):
                    self.imageView.image = image
                case let .failure(error):
                    print("Error fetching image for photo: \(error)")
            }
        }
        
        //code for Bronze Challenge: Photo View Count
        photo.viewCount += 1
        store.saveContextIfNeeded()
        
        viewLabel.text = "\(photo.viewCount) number of views"
        viewLabel.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    //passes along the photo and the store during the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showTags"?:
            let navController = segue.destination as! UINavigationController
            let tagController = navController.topViewController as! TagsViewController
            
            tagController.store = store
            tagController.photo = photo
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
}
