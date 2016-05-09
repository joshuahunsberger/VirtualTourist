//
//  Photo.swift
//  VirtualTourist
//
//  Created by Joshua Hunsberger on 4/24/16.
//  Copyright © 2016 Joshua Hunsberger. All rights reserved.
//

import UIKit
import CoreData

class Photo: NSManagedObject {
    // MARK: Properties
    @NSManaged var urlPath: String!
    @NSManaged var id: String!
    @NSManaged var location: Pin?
    
    // MARK: Initializers
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(id: String, path: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.id = id
        urlPath = path
    }
    
    override func prepareForDeletion() {
        // Build URL
        let documentsPath = CoreDataStackManager.sharedManager.applicationDocumentsDirectory
        let fileURL = NSURL.fileURLWithPath("\(id)", relativeToURL: documentsPath)
        let filePath = fileURL.path!
        
        let fileManager = NSFileManager()
        
        // Delete the file for the image if it exists
        if fileManager.fileExistsAtPath(filePath) {
            do {
                try fileManager.removeItemAtPath(filePath)
            } catch let error as NSError {
                print("There was an error removing the file: \(error.localizedDescription)")
            }
        }

    }
}