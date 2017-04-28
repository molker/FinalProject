//
//  PhotosViewController.swift
//  Photorama
//
//  Created by Matthew Olker on 4/19/17.
//  Copyright © 2017 Matthew Olker. All rights reserved.
//  sets up the UI for photorama

import UIKit

class PhotosViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var store: PhotoStore!
    //adds a property to reference an instance of photodatasource
    let photoDataSource = PhotoDataSource()
    
    //kicks off the web service exchange when the view controller comes onscreen for the first time
    //updates the data source object and reloads the collection view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sets the data source on the collection view
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self
        
        updateDataSource()
        
        store.fetchInterestingPhotos {
            (photosResult) -> Void in
            
            self.updateDataSource()
        }
    }
    
    //required so PhotosViewController can be a UICollectionView delegate
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let photo = photoDataSource.photos[indexPath.row]
        
        //Download the image data which could take some time
        store.fetchImage(for: photo) { (result) -> Void in
            
            //The index path for the photo might have changed between the
            //time the request started and finished, so find the most
            //recent index path
            
            guard let photoIndex = self.photoDataSource.photos.index(of: photo),
                case let .success(image) = result else {
                    return
            }
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)
            
            //When the reqeust finishes, only update the cell if it's still visible 
            if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
                cell.update(with: image)
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showPhoto"?:
            if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
                let photo = photoDataSource.photos[selectedIndexPath.row]
                
                let destinationVC = segue.destination as! PhotoInfoViewController
                destinationVC.photo = photo
                destinationVC.store = store
            }
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
    
    private func updateDataSource() {
        store.fetchAllPhotos {
            (photosResult) in
            
            switch photosResult {
            case let .success(photos):
                self.photoDataSource.photos = photos
            case .failure:
                self.photoDataSource.photos.removeAll()
            }
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
}

//code for Silver Challenge: Updated Item Sizes
extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    //changes the size of the cells so there will be 4 items per row
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.size.width
        let numberOfItemsPerRow: CGFloat = 4
        let itemWidth = collectionViewWidth / numberOfItemsPerRow
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.reloadData()
    }
}
