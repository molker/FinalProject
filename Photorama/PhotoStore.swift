//
//  PhotoStore.swift
//  Photorama
//
//  Created by Matthew Olker on 4/19/17.
//  Copyright © 2017 Matthew Olker. All rights reserved.
//  responsible for initiating web service requests

import UIKit
import CoreData

//represents the result of downloading the image (follows same pattern as PhotoResult)
enum ImageResult {
    case success(UIImage)
    case failure(Error)
}

//represents an error to represent photo errors
enum PhotoError: Error {
    case imageCreationError
}

//if data is valid JSON and contains photos, photos will associate with the success case
//any errors during the parsing process with pass an error with the failure case
enum PhotosResult {
    case success([Photo])
    case failure(Error)
}

//result type for when fetching tags
enum TagsResult {
    case success([Tag])
    case failure(Error)
}

class PhotoStore {
    
    let imageStore = ImageStore()
    
    //holds on to an instance of NSPersistentContainer
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Photorama")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error setting up Core Data (\(error)).")
            }
        }
        return container
    }()
    
    //holds onto an instance of URLSession
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    //creates a URLrequest that connects to api.flickr.com and asks for the list of interesting photos
    //then creates a URLSessionDataTask that transfers the request to the server
    func fetchInterestingPhotos(completion: @escaping (PhotosResult) -> Void) {
        
        let url = FlickrAPI.interestingPhotosURL
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) {
            (data, resposne, error) -> Void in
            
            //Code for Bronze Challenge: Printing the Response Information
            if let httpStatus = resposne as? HTTPURLResponse {
                //check for http errors
                print("fetchInterestingPhotos")
                print("statusCode is \(httpStatus.allHeaderFields)")
                print("Header fields are \(httpStatus.allHeaderFields)")
            }
            
            //saves changes to context after photo entities have been inserted into the context
            self.processPhotosRequest(data: data, error: error) {
                (result) in
                
                OperationQueue.main.addOperation {
                    completion(result)
                }
            }
        }
        task.resume()
    }
    
    //downloads the image data an dsaves the images using the imageStore
    func fetchImage(for photo: Photo, completion: @escaping (ImageResult) -> Void) {
        
        let photoKey = photo.photoID
        if let image = imageStore.image(forKey: photoKey! ) {
            OperationQueue.main.addOperation {
                completion(.success(image))
            }
            return
        }
        
        let photoURL = photo.remoteURL
        let request = URLRequest(url: photoURL as! URL)
        
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            //Code for Bronze Challenge: Printing the Response Information
            if let httpStatus = response as? HTTPURLResponse {
                //check for http errors
                print("fetchImage:")
                print("statusCode: \(httpStatus.statusCode)")
                print("Header fields: \(httpStatus.allHeaderFields)")
            }
            
            let result = self.processImageRequest(data: data, error: error)
            
            if case let .success(image) = result {
                self.imageStore.setImage(image, forKey: photoKey!)
            }
            
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    //processes the data from the web service request into an image, if possible
    private func processImageRequest(data: Data?, error: Error?) -> ImageResult {
        guard
            let imageData = data,
            let image = UIImage(data: imageData) else {
                //Couldn't create an image
                if data == nil {
                    return .failure(error!)
                } else {
                    return .failure(PhotoError.imageCreationError)
                }
        }
        return .success(image)
    }
    
    //processes JSON data that is returned from the web service request
    private func processPhotosRequest(data: Data?, error: Error?, completion: @escaping (PhotosResult) -> Void) {
        guard let jsonData = data else {
            completion(.failure(error!))
            return
        }
        
        persistentContainer.performBackgroundTask {
            (context) in
            
            let result = FlickrAPI.photos(fromJson: jsonData, into: context)
            
            do {
                try context.save()
            } catch {
                print("Error saving to Core Data: \(error).")
                completion(.failure(error))
                return
            }
            
            switch result {
            case let .success(photos):
                let photoIDs = photos.map { return $0.objectID }
                let viewContext = self.persistentContainer.viewContext
                let viewContextPhotos =
                    photoIDs.map { return viewContext.object(with: $0) } as! [Photo]
                completion(.success(viewContextPhotos))
            case .failure:
                completion(result)
            }
        }
    }
    
    //fetches photo instances from the view context
    func fetchAllPhotos(completion: @escaping (PhotosResult) -> Void) {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortByDateTaken = NSSortDescriptor(key: #keyPath(Photo.dateTaken), ascending: true)
        fetchRequest.sortDescriptors = [sortByDateTaken]
        
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allPhotos = try viewContext.fetch(fetchRequest)
                completion(.success(allPhotos))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    //fetches all the tags from the view context
    func fetchAllTags(completion: @escaping (TagsResult) -> Void) {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        let sortByName = NSSortDescriptor(key: #keyPath(Tag.name), ascending: true)
        fetchRequest.sortDescriptors = [sortByName]
        
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allTags = try fetchRequest.execute()
                completion(.success(allTags))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    //code for Bronze Challenge: Photo View Count
    func saveContextIfNeeded() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            print("Save context")
            try? context.save()
        }
    }

}
