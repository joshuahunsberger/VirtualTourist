//
//  Pin.swift
//  VirtualTourist
//
//  Created by Joshua Hunsberger on 4/18/16.
//  Copyright © 2016 Joshua Hunsberger. All rights reserved.
//

import MapKit
import CoreData

class Pin: NSManagedObject {
    // MARK: Properties
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var photos: [Photo]
    
    // MARK: Initializers
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(pin: MKPointAnnotation, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        latitude = pin.coordinate.latitude
        longitude = pin.coordinate.longitude
    }
    
    init(location: CLLocationCoordinate2D, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        latitude = location.latitude
        longitude = location.longitude
    }
    
    // Computed property for annotation
    
    var annotation : MKPointAnnotation {
        let pin = MKPointAnnotation()
        pin.coordinate.latitude = latitude.doubleValue
        pin.coordinate.longitude = longitude.doubleValue
        
        return pin
    }
    
}