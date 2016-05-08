//
//  TravelMapViewController.swift
//  VirtualTourist
//
//  Created by Joshua Hunsberger on 4/18/16.
//  Copyright © 2016 Joshua Hunsberger. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelMapViewController: UIViewController, MKMapViewDelegate {

    // MARK: InterfaceBuilder Outlet properties
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Properties
    var pins = [Pin]()
    
    // MARK: View lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLongPressRecognizer()
        
        mapView.delegate = self
        
        // Check if map region previously set, as stored in NSUserDefaults.  If so, set it.
        // The doubleForKey function returns 0 if the key doesn't exist, and a latitude delta of 0 shouldn't make sense.
        if NSUserDefaults.standardUserDefaults().doubleForKey("latitudeDelta") != 0 {
            let lat = NSUserDefaults.standardUserDefaults().doubleForKey("latitude")
            let lon = NSUserDefaults.standardUserDefaults().doubleForKey("longitude")
            let latDelta = NSUserDefaults.standardUserDefaults().doubleForKey("latitudeDelta")
            let lonDelta = NSUserDefaults.standardUserDefaults().doubleForKey("longitudeDelta")
            
            mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(lat, lon), MKCoordinateSpanMake(latDelta, lonDelta)), animated: false)
        }
        
        // Load pins from Core Data
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        do {
            let results = try sharedContext.executeFetchRequest(fetchRequest)
            for result in results {
                let pin = result as! Pin
                pins.append(pin)
                mapView.addAnnotation(pin.annotation)
            }
        } catch {
            // Error fetching saved pins
            print("Error fetching saved pins.")
        }
    }

    // Core Data convenience property for context
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedManager.managedObjectContext
    }
    
    /**
        This function captures a location from a gesture recognizer and
        creates a pin on the map view at that location.
    
        - Parameter recognizer: The gesture recognizer object that will capture long press gestures
    */
    func addPinFromLongPress(recognizer: UILongPressGestureRecognizer) {
        if (recognizer.state != UIGestureRecognizerState.Began) {
            return
        }
        
        let point = recognizer.locationInView(mapView)
        let location = mapView.convertPoint(point, toCoordinateFromView: mapView)
        
        let pin = Pin(location: location, context: sharedContext)
        pins.append(pin)
        mapView.addAnnotation(pin.annotation)
        
        CoreDataStackManager.sharedManager.saveContext()
    }
    
    /// Function to lay out what happens when segues are triggerd
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showPhotoAlbumSegue") {
            let vc = segue.destinationViewController as! PhotoAlbumViewController
            let annotation = sender as! MKPointAnnotation
            
            for pin in pins {
                if (pin.latitude == annotation.coordinate.latitude && pin.longitude == annotation.coordinate.longitude) {
                    vc.pin = pin
                    break
                }
            }
        }
    }
    
    // MARK: UI Setup functions
    
    /// Creates a long press gesture recognizer and adds it to the map view
    func addLongPressRecognizer() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(TravelMapViewController.addPinFromLongPress))
        mapView.addGestureRecognizer(longPressRecognizer)
    }
    
    // MARK: MKMapView Delegate Functions
    
    /// Triggers a segue to the photo album view whenever a pin is pressed 
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        performSegueWithIdentifier("showPhotoAlbumSegue", sender: view.annotation)
    }
    
    /**
        Triggered whenever the region of the map finishes changing.
     
        Use this delegate function to save values to NSUserDefaults that are needed to reconstruct the map region.
    */
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.center.latitude, forKey: "latitude")
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.center.longitude, forKey: "longitude")
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.span.latitudeDelta, forKey: "latitudeDelta")
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.span.longitudeDelta, forKey: "longitudeDelta")
    }
}

