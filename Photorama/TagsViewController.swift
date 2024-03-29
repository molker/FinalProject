//
//  TagsViewController.swift
//  Photorama
//
//  Created by Matthew Olker on 4/27/17.
//  Copyright © 2017 Matthew Olker. All rights reserved.
//  displays a list of all tags. user will be able to select the tags that are associated with a specific photo

import UIKit
import CoreData

class TagsViewController: UITableViewController {
    
    var store: PhotoStore!
    var photo: Photo!
    
    //keeps track of currently selected tags
    var selectedIndexPaths = [IndexPath]()
    
    let tagDataSource = TagDataSource()
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    //adds a new tag to the selected tags for use with the button 
    @IBAction func addNewTag(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Add Tag", message: nil, preferredStyle: .alert)
        
        alertController.addTextField {
            (textField) -> Void in
            textField.placeholder = "tag name"
            textField.autocapitalizationType = .words
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) {
            (action) -> Void in
            
            if let tagName = alertController.textFields?.first?.text {
                let context = self.store.persistentContainer.viewContext
                let newTag = NSEntityDescription.insertNewObject(forEntityName: "Tag", into: context)
                
                newTag.setValue(tagName, forKey: "name")
                
                do {
                    try self.store.persistentContainer.viewContext.save()
                } catch let error {
                    print("Core Data save failed: \(error)")
                }
                self.updateTags()
            }
        }
        alertController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    //sets the datasource and delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = tagDataSource
        tableView.delegate = self
        
        updateTags()
    }
    
    //fetches tags and associates them with the tags property on the data source and adds index paths to the selectedIndexPaths array
    func updateTags() {
        store.fetchAllTags {
            (tagsResult) in
            
            switch tagsResult {
            case let .success(tags):
                self.tagDataSource.tags = tags
                
                guard let photoTags = self.photo.tags as? Set<Tag> else {
                    return
                }
                
                for tag in photoTags {
                    if let index = self.tagDataSource.tags.index(of: tag) {
                        let indexPath = IndexPath(row: index, section: 0)
                        self.selectedIndexPaths.append(indexPath)
                    }
                }
            case let .failure(error):
                print("Error fetching tags: \(error).")
            }
            
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    
    //handles selected pictures
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let tag = tagDataSource.tags[indexPath.row]
        
        if let index = selectedIndexPaths.index(of: indexPath) {
            selectedIndexPaths.remove(at: index)
            photo.removeFromTags(tag)
        } else {
            selectedIndexPaths.append(indexPath)
            photo.addToTags(tag)
        }
        
        do {
            try store.persistentContainer.viewContext.save()
        } catch {
            print("Core Data save failed: \(error).")
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    //displays checkmarks
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if selectedIndexPaths.index(of: indexPath) != nil {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }
    
}
