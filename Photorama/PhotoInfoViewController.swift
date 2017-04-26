//
//  PhotoInfoViewController.swift
//  Photorama
//
//  Created by Matthew Olker on 4/26/17.
//  Copyright © 2017 Matthew Olker. All rights reserved.
//

import UIKit

class PhotoInfoViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    
    var photo: Photo! {
        didSet {
            navigationItem.title = photo.title
        }
    }
    var store: PhotoStore!
    
}
