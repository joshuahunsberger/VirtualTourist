//
//  Photo.swift
//  VirtualTourist
//
//  Created by Joshua Hunsberger on 4/24/16.
//  Copyright © 2016 Joshua Hunsberger. All rights reserved.
//

import UIKit

class Photo {
    // MARK: Properties
    var urlPath: String!
    var location: Pin?
    
    // MARK: Initializers
    
    init(path: String) {
        urlPath = path
    }
}