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

    /**
        This method queries Flickr for photos at a given longitude and latitude.  If there is more than one page of results, it picks a 
        random page and calls another function to request that page.
     
        - Parameters:
          - latitude: Latitude to search
          - longitude: Longitude to search
          - completionHandlerForSearchPhotos: Completion handler to call on success or error condition
     */
    func searchPhotosByLatLon(latitude: Double, longitude: Double, completionHandlerForSearchPhotos: (photos: [Photo]?, error: NSError?) -> Void) {
        
        func sendError(error: String){
            let userInfo = [NSLocalizedDescriptionKey: error]
            completionHandlerForSearchPhotos(photos: nil, error: NSError(domain: "searchPhotosByLatLon", code: 1, userInfo: userInfo))
        }
        
        let parameters : [String: AnyObject] = [
            ParameterKeys.Method : ParameterValues.SearchMethod,
            ParameterKeys.APIKey : ParameterValues.APIKey,
            ParameterKeys.Extras : ParameterValues.MediumURL,
            ParameterKeys.Format : ParameterValues.ResponseFormat,
            ParameterKeys.NoJSONCallback : ParameterValues.DisableJSONCallback,
            ParameterKeys.SafeSearch : ParameterValues.UseSafeSearch,
            ParameterKeys.BoundingBox : getBoundingBox(latitude, lon: longitude),
            ParameterKeys.PerPage : ParameterValues.PhotosPerPage
        ]
        
        taskForGetMethod(parameters) { (result, error) in
            guard (error == nil) else {
                sendError(error!.localizedDescription)
                return
            }
            
            // Check status from Flickr
            guard let stat = result[ResponseKeys.Status] as? String where stat == ResponseValues.OKStatus else {
                sendError("Flickr returned an error.")
                return
            }
            
            // Try to parse Photos dictionary
            guard let photosDictionary = result[ResponseKeys.Photos] as? [String: AnyObject] else {
                sendError("Unable to access photos.")
                return
            }
            
            // Try to parse Photo array
            guard let photoArray = photosDictionary[ResponseKeys.Photo] as? [[String: AnyObject]] else {
                sendError("Unable to access photo array.")
                return
            }
            
            if photoArray.count == 0 {
                sendError("No photos found.")
                return
            }
            
            guard let numPages = photosDictionary[ResponseKeys.Pages] as? Int else {
                sendError("Cannot retrieve page count.")
                return
            }

            // Pick a random page
            // Flickr doesn't seem to return more than 1000 pictures, so only search up to page 33 (1000/30 = 33 pages)
            let pageLimit = min(numPages, 33)
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            if(randomPage == 1) {
                // Already have the page we want, use the images on this page
                var photoURLs = [Photo]()
                for photo in photoArray {
                    if let urlString = photo[ResponseKeys.MediumURL] as? String {
                        if let id = photo[ResponseKeys.ID] as? String {
                            let photoObject = Photo(id: id, path: urlString, context: CoreDataStackManager.sharedManager.managedObjectContext)
                            photoURLs.append(photoObject)
                        }
                    }
                }
                completionHandlerForSearchPhotos(photos: photoURLs, error: nil)
            } else {
                var newParameters = parameters
                newParameters[ParameterKeys.Page] = "\(randomPage)"
                self.searchPhotosByLatLon(newParameters, completionHandlerForSearchPhotos: completionHandlerForSearchPhotos)
            }
        }
    }
    
    /**
        This method queries Flickr for photos at a given longitude and latitude and a specific page in the result set.
     
        This function should be called after choosing a specific page of results to display.

        - Parameters:
          - parameters: The list of parameters to search
          - completionHandlerForSearchPhotos: Completion handler to call on success or error condition
     */
    func searchPhotosByLatLon(parameters: [String: AnyObject], completionHandlerForSearchPhotos: (photos: [Photo]?, error: NSError?) -> Void) {
        func sendError(error: String){
            let userInfo = [NSLocalizedDescriptionKey: error]
            completionHandlerForSearchPhotos(photos: nil, error: NSError(domain: "searchPhotosByLatLon", code: 1, userInfo: userInfo))
        }
        
        taskForGetMethod(parameters) { (result, error) in
            
            guard (error == nil) else {
                sendError(error!.localizedDescription)
                return
            }
            
            // Check status from Flickr
            guard let stat = result[ResponseKeys.Status] as? String where stat == ResponseValues.OKStatus else {
                sendError("Flickr returned an error.")
                return
            }
            
            // Try to parse Photos dictionary
            guard let photosDictionary = result[ResponseKeys.Photos] as? [String: AnyObject] else {
                sendError("Unable to access photos.")
                return
            }
            
            // Try to parse Photo array
            guard let photoArray = photosDictionary[ResponseKeys.Photo] as? [[String: AnyObject]] else {
                sendError("Unable to access photo array.")
                return
            }
            
            if photoArray.count == 0 {
                sendError("No photos found on page. Consider searching fewer pages.")
                return
            }
            
            var photoURLs = [Photo]()
            for photo in photoArray {
                if let urlString = photo[ResponseKeys.MediumURL] as? String {
                    if let id = photo[ResponseKeys.ID] as? String {
                        let photoObject = Photo(id: id, path: urlString, context: CoreDataStackManager.sharedManager.managedObjectContext)
                        photoURLs.append(photoObject)
                    }
                }
            }
            completionHandlerForSearchPhotos(photos: photoURLs, error: nil)
        }
    }
}
