//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Joshua Hunsberger on 4/23/16.
//  Copyright © 2016 Joshua Hunsberger. All rights reserved.
//

import Foundation

class FlickrClient: NSObject {
    
    // MARK: Properties
    var session = NSURLSession.sharedSession()
    
    // Make FlickrClient a singleton with a single line.
    // From http://krakendev.io/blog/the-right-way-to-write-a-singleton
    static let sharedInstance = FlickrClient()
    
    // MARK: GET
    func taskForGetMethod(parameters: [String: AnyObject]?, completionHandlerForGet: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let request = NSURLRequest(URL: createFlickrURLFromParameters(parameters!))
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            self.processDataWithCompletionHandler(data, response: response, error: error, completionHandlerForProcessData: completionHandlerForGet)
        }
        task.resume()
        
        return task
    }
    
    // MARK: Helper Functions
    
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
    
    func processDataWithCompletionHandler(data: NSData?, response: NSURLResponse?, error: NSError?, completionHandlerForProcessData: (result: AnyObject!, error: NSError?) -> Void) {
        func sendError(error: String){
            let userInfo = [NSLocalizedDescriptionKey: error]
            completionHandlerForProcessData(result: nil, error: NSError(domain: "processDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        // Check for errors from data returned from Flickr
        guard (error == nil) else {
            sendError(error!.localizedDescription)
            return
        }
        
        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode else {
            sendError("Unable to retrieve status code.")
            return
        }
        
        guard statusCode >= 200 && statusCode <= 299 else {
            sendError("Request returned invalid status code.")
            return
        }
        
        guard let data = data else{
            sendError("No data returned.")
            return
        }
        
        // Attempt to parse the data as JSON
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            sendError("Could not parse data as JSON: \(data)")
        }
        
        completionHandlerForProcessData(result: parsedResult, error: nil)
    }
}