//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Joshua Hunsberger on 4/24/16.
//  Copyright © 2016 Joshua Hunsberger. All rights reserved.
//

extension FlickrClient {
    
    struct Constants {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
        
        static let MinLat = -90
        static let MaxLat = 90
        static let MinLon = -180
        static let MaxLong = 180
    }
    
    struct ParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let BoundingBox = "bbox"
    }
    
    struct ParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "" /* Specify your API Key here. */
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
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