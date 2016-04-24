//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Joshua Hunsberger on 4/23/16.
//  Copyright © 2016 Joshua Hunsberger. All rights reserved.
//

import Foundation

class FlickrClient: NSObject {
    
    // Make FlickrClient a singleton with a single line.
    // From http://krakendev.io/blog/the-right-way-to-write-a-singleton
    static let sharedInstance = FlickrClient()
    
    // MARK: URL Helper Function
    
    func createFlickrURLFromParameters(parameters: [String: AnyObject]) -> NSURL {
        let components = NSURLComponents()
        components.scheme = Constants.APIScheme
        components.host = Constants.APIHost
        components.path = Constants.APIPath
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
}