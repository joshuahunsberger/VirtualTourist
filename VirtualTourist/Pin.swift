//
//  Pin.swift
//  VirtualTourist
//
//  Created by Joshua Hunsberger on 4/18/16.
//  Copyright © 2016 Joshua Hunsberger. All rights reserved.
//

import MapKit

class Pin {
    // MARK: Properties
    var latitude: Double
    var longitude: Double
    var photos = [Photo]()
    
    // MARK: Initializers
    
    init(pin: MKPointAnnotation) {
        latitude = pin.coordinate.latitude
        longitude = pin.coordinate.longitude
    }
    
    init(location: CLLocationCoordinate2D) {
        latitude = location.latitude
        longitude = location.longitude
    }
    
    // Computed property for annotation
    
    var annotation : MKPointAnnotation {
        let pin = MKPointAnnotation()
        pin.coordinate.latitude = latitude
        pin.coordinate.longitude = longitude
        
        return pin
    }
    
}