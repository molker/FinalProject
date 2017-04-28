//
//  TagDataSource.swift
//  Photorama
//
//  Created by Matthew Olker on 4/27/17.
//  Copyright © 2017 Matthew Olker. All rights reserved.
//  displays the list of tags in the table view

import UIKit
import CoreData

class TagDataSource: NSObject, UITableViewDataSource {
    
    var tags: [Tag] = []
    //required method for letting the class be a data source that gives the number of tags
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    //required method for letting the class be a data source that creates and sets up a cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        
        let tag = tags[indexPath.row]
        cell.textLabel?.text = tag.name
        
        return cell
    }
    
}
