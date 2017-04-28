//
//  PhotoDataSource.swift
//  Photorama
//
//  Created by Matthew Olker on 4/26/17.
//  Copyright © 2017 Matthew Olker. All rights reserved.
//

import UIKit

class PhotoDataSource: NSObject, UICollectionViewDataSource {
    
    var photos = [Photo]()
    
    //asks how many cells to display 
    //required for letting this class be a collection view data source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    //Asks the UICollectionViewCell to display for a given index path
    //required for letting this class be a collection view data source
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier = "PhotoCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        return cell
        
    }
    
}
