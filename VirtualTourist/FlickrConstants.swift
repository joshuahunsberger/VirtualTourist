//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Joshua Hunsberger on 4/24/16.
//  Copyright © 2016 Joshua Hunsberger. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    struct Constants {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
        
        // Coordinates in Radians
        static let MIN_LAT = -90.0 * M_PI/180.0
        static let MAX_LAT = 90.0 * M_PI/180.0
        static let MIN_LON = -180.0 * M_PI/180.0
        static let MAX_LON = 180.0 * M_PI/180.0
        
        // Constants to help compute bounding box
        static let EARTH_RADIUS_KM = 6371.0
        static let SEARCH_DISTANCE_KM = 5.0
    }
    
    struct ParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let BoundingBox = "bbox"
        static let PerPage = "per_page"
    }
    
    struct ParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "" /* Specify your API Key here. */
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
        static let PhotosPerPage = "30"
    }
    
    struct ResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
    }
    
    struct ResponseValues {
        static let OKStatus = "ok"
    }
}