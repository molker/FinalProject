//
//  PhotoCollectionViewCell.swift
//  Photorama
//
//  Created by Matthew Olker on 4/26/17.
//  Copyright © 2017 Matthew Olker. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    //helps update teh spinner when the imageView is updated
    func update(with image: UIImage?) {
        if let imageToDisplay = image {
            spinner.stopAnimating()
            imageView.image = imageToDisplay
        } else {
            spinner.startAnimating()
            imageView.image = nil
        }
    }
    
    //resets each cell to the spinning state when first created
    override func awakeFromNib() {
        super.awakeFromNib()
        
        update(with: nil)
    }
    
    //resets each cell to the spinning state when cell is getting reused
    override func prepareForReuse() {
        super.prepareForReuse()
        
        update(with: nil)
    }
    
}
