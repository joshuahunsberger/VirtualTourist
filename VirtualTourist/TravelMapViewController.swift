//
//  TravelMapViewController.swift
//  VirtualTourist
//
//  Created by Joshua Hunsberger on 4/18/16.
//  Copyright © 2016 Joshua Hunsberger. All rights reserved.
//

import UIKit
import MapKit

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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.hidden = false
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
        
        let pin = Pin(location: location)
        pins.append(pin)
        mapView.addAnnotation(pin.annotation)
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
}

