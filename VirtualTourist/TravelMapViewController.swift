//
//  TravelMapViewController.swift
//  VirtualTourist
//
//  Created by Joshua Hunsberger on 4/18/16.
//  Copyright © 2016 Joshua Hunsberger. All rights reserved.
//

import UIKit
import MapKit

class TravelMapViewController: UIViewController {

    // MARK: InterfaceBuilder Outlet properties
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: View lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLongPressRecognizer()
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
        
        mapView.addAnnotation(pin.annotation)
    }
    
    // MARK: UI Setup functions
    
    /// Creates a long press gesture recognizer and adds it to the map view
    func addLongPressRecognizer() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(TravelMapViewController.addPinFromLongPress))
        mapView.addGestureRecognizer(longPressRecognizer)
    }
}

