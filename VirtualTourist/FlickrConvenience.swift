//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Joshua Hunsberger on 4/24/16.
//  Copyright © 2016 Joshua Hunsberger. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    /**
        This function outputs a comma-delimited list of coordinates defining the
        bounding box that Flickr will search.
     
        Flickr expects the following four values (in degrees): 
        - minimum_longitude 
        - minimum_latitude 
        - maximum_longitude
        - maximum_latitude
        
        The coordinates calculated using the great circle distance formula for the earth's surface. The radius
        of the Earth and distance of the desired are stored as constants.
     
        This function is converted from Jan Philip Matuschek's Java sample code.
        The code and details of the fourmulas are found here:
        [http://janmatuschek.de/LatitudeLongitudeBoundingCoordinates](http://janmatuschek.de/LatitudeLongitudeBoundingCoordinates)
     
     - parameters:
          - lat: The latitude of the center of the area to be searched
          - lon: The longitude of the center of the area to be searched
     - returns: A comma-delimited string of coordinates indicating the bottom-left corner of the box and the top-right corner.
    */
    func getBoundingBox(lat: Double, lon: Double) -> String{
        let radius = Constants.EARTH_RADIUS_KM
        let distance = Constants.SEARCH_DISTANCE_KM
        
        let min_lat = Constants.MIN_LAT
        let max_lat = Constants.MAX_LAT
        let min_lon = Constants.MIN_LON
        let max_lon = Constants.MAX_LON
        
        // Convert values to radians for calculation
        
        let radDist = distance/radius
        
        let radLat = lat * M_PI / 180
        let radLon = lon * M_PI / 180
        
        // Compute min/max latitude values for bounding box
        var minBoxLat = radLat - radDist
        var maxBoxLat = radLat + radDist
        
        // Compute the min/max longitude values for bounding box
        var minBoxLon, maxBoxLon : Double
        if (minBoxLat > min_lat && maxBoxLat < max_lat) {
            let deltaLon = asin(sin(radDist) / cos(radLat))
            minBoxLon = radLon - deltaLon
            if (minBoxLon < min_lon) {minBoxLon += 2.0 * M_PI}
            maxBoxLon = radLon + deltaLon;
            if (maxBoxLon > max_lon) {maxBoxLon -= 2.0 * M_PI}
        } else{
            // Handle coordinates that overlap the earth's poles
            minBoxLat = max(minBoxLat, min_lat);
            maxBoxLat = min(maxBoxLat, max_lat);
            minBoxLon = min_lon;
            maxBoxLon = max_lon;
        }
        
        // Convert coordinates from radians back to degrees
        minBoxLon *= 180.0/M_PI
        minBoxLat *= 180.0/M_PI
        maxBoxLon *= 180.0/M_PI
        maxBoxLat *= 180.0/M_PI
        
        return "\(minBoxLon),\(minBoxLat),\(maxBoxLon),\(maxBoxLat)"
    }

    
}