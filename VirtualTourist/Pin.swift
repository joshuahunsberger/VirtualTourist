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
    let annotation: MKPointAnnotation!
    
    // MARK: Initializers
    
    init(pin: MKPointAnnotation) {
        annotation = pin
    }
    
    init(location: CLLocationCoordinate2D) {
        annotation = MKPointAnnotation()
        annotation.coordinate = location
    }
}