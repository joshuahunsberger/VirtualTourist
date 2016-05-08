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
    // MARK: Enumeration defining the current editing mode of the view controller
    enum EditingMode {
        case editingOn
        case editingOff
    }
    
    
    // MARK: Constants
    
    let DELETE_LABEL_HEIGHT_EXPANDED: CGFloat  = 50.0
    let DELETE_LABEL_HEIGHT_COLLAPSED: CGFloat = 0.0
    let ANIMATION_DURATION: Double = 0.1


    // MARK: InterfaceBuilder Outlet properties
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deleteLabel: UILabel!
    @IBOutlet weak var deleteLabelHeightConstraint: NSLayoutConstraint!
    
    
    // MARK: Properties
    
    var pins = [Pin]()
    var mode: EditingMode!
    
    
    // MARK: View lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLongPressRecognizer()
        initializeEditingMode()
        
        mapView.delegate = self
        
        initializeMapRegion()
        
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
    
    /**
        This function toggles the class mode property and updates the UI to reflect the current 
        editing state.
     
        The mode property is used by other functions to determine the behavior that should be applied
        to different actions.
    */
    func toggleEditingMode() {
        if(mode == EditingMode.editingOff) {
            mode = EditingMode.editingOn
            navigationItem.rightBarButtonItem?.style = .Done
            navigationItem.rightBarButtonItem?.title = "Done"
            deleteLabelHeightConstraint.constant = DELETE_LABEL_HEIGHT_EXPANDED
        } else {
            mode = EditingMode.editingOff
            navigationItem.rightBarButtonItem?.style = .Plain
            navigationItem.rightBarButtonItem?.title = "Edit"
            deleteLabelHeightConstraint.constant = DELETE_LABEL_HEIGHT_COLLAPSED
        }
        
        deleteLabel.hidden = !deleteLabel.hidden
        
        // Animate the layout change to make the transition smoother, as indicated by this StackOverFlow
        // answer: http://stackoverflow.com/a/25650669/6217795
        UIView.animateWithDuration(ANIMATION_DURATION) {
            self.view.layoutIfNeeded()
        }
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
    
    /// Initializes the editing mode to off and sets up the UI elements for toggling that status
    func initializeEditingMode() {
        let editButton = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: #selector(TravelMapViewController.toggleEditingMode))
        navigationItem.rightBarButtonItem = editButton
        mode = EditingMode.editingOff
        deleteLabel.hidden = true
        deleteLabelHeightConstraint.constant = DELETE_LABEL_HEIGHT_COLLAPSED
    }
    
    /**
        Initializes the map region
        
        Check if map region previously set, as stored in NSUserDefaults.  If so, set it.
        The doubleForKey function returns 0 if the key doesn't exist, and a latitude delta of 0 shouldn't make sense.
    */
    func initializeMapRegion() {
        if NSUserDefaults.standardUserDefaults().doubleForKey("latitudeDelta") != 0 {
            let lat = NSUserDefaults.standardUserDefaults().doubleForKey("latitude")
            let lon = NSUserDefaults.standardUserDefaults().doubleForKey("longitude")
            let latDelta = NSUserDefaults.standardUserDefaults().doubleForKey("latitudeDelta")
            let lonDelta = NSUserDefaults.standardUserDefaults().doubleForKey("longitudeDelta")
            
            mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(lat, lon), MKCoordinateSpanMake(latDelta, lonDelta)), animated: false)
        }
    }
    
    // MARK: MKMapView Delegate Functions
    
    /**
        Handles a press of an annotation based on the currently active editing mode.
     
        -EditingMode.editingOff: Triggers a segue to the photo album view whenever a pin is pressed
        -EditingMode.editingOn: Deletes the selected pin.
    */
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if(mode == EditingMode.editingOff){
            mapView.deselectAnnotation(view.annotation, animated: true)
            performSegueWithIdentifier("showPhotoAlbumSegue", sender: view.annotation)
        } else {
            let annotation = view.annotation as! MKPointAnnotation
            for pin in pins {
                if (pin.latitude == annotation.coordinate.latitude && pin.longitude == annotation.coordinate.longitude) {
                    sharedContext.deleteObject(pin)
                    pins.removeAtIndex(pins.indexOf(pin)!)
                    mapView.removeAnnotation(annotation)
                    CoreDataStackManager.sharedManager.saveContext()
                    break
                }
            }
        }
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

