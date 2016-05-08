//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Joshua Hunsberger on 4/19/16.
//  Copyright © 2016 Joshua Hunsberger. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: Properties
    var pin: Pin!
    let activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0,50,50))
    var selectedIndexes = [NSIndexPath]()
    
    // MARK: InterfaceBuilder outlet properties
    
    @IBOutlet weak var pinMapView: MKMapView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var photoUpdateButton: UIBarButtonItem!
    
    
    // MARK: View lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error fetching data: \(error.localizedDescription)")
        }
        
        if let pin = pin {
            pinMapView.showAnnotations([pin.annotation], animated: true)
            
            if pin.photos.isEmpty {
                downloadFlickrImages()
            }
        }
        
        let flowLayout = UICollectionViewFlowLayout()
        let space: CGFloat = 3.0
        let minOrientationSize = min(photoCollectionView.frame.size.height, photoCollectionView.frame.size.width)
        let dimension = (minOrientationSize - (2*space)) / 3.0
        flowLayout.minimumLineSpacing = space
        flowLayout.minimumInteritemSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
        
        photoCollectionView.setCollectionViewLayout(flowLayout, animated: false)
    }
    
    
    // MARK: Core Data Convenience Methods/Properties
    
    var sharedContext = CoreDataStackManager.sharedManager.managedObjectContext
    
    func saveContext() {
        CoreDataStackManager.sharedManager.saveContext()
    }
    
    // Fetched Results Controller
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "location == %@", self.pin)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    /// This function downloads a list of images from Flickr and updates the collection view on completion
    func downloadFlickrImages() {
        photoUpdateButton.enabled = false
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        view.addSubview(activityIndicator)
        activityIndicator.frame = view.frame
        activityIndicator.center = view.center
        activityIndicator.layer.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.75).CGColor
        activityIndicator.startAnimating()
        
        
        FlickrClient.sharedInstance.searchPhotosByLatLon(pin.annotation.coordinate.latitude, longitude: pin.annotation.coordinate.longitude) { (photos, error) in
            guard (error == nil) else {
                print("Error: \(error!.localizedDescription)")
                dispatch_async(dispatch_get_main_queue()) {
                    self.enableUIAndRemoveActivityIndicator()
                }
                return
            }
            
            guard let photoArray = photos else {
                print("Error accessing photos.")
                dispatch_async(dispatch_get_main_queue()) {
                    self.enableUIAndRemoveActivityIndicator()
                }
                return
            }
            
            for photo in photoArray {
                photo.location = self.pin
            }
            
            self.saveContext()
            
            dispatch_async(dispatch_get_main_queue()) {
                self.photoCollectionView.reloadData()
                self.enableUIAndRemoveActivityIndicator()
            }
        }
    }
    
    
    // MARK: Collection View Methods
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = photoCollectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCollectionViewCell
        
        if let index = selectedIndexes.indexOf(indexPath) {
            selectedIndexes.removeAtIndex(index)
            cell.photoImageView.alpha = 1.0
        } else {
            selectedIndexes.append(indexPath)
            cell.photoImageView.alpha = 0.5
        }
        
        // Update the title of the bottom button
        updateBottomButton()
    }
    
    func configureCell(cell: PhotoCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        // Build URL
        let documentsPath = CoreDataStackManager.sharedManager.applicationDocumentsDirectory
        let filePath = NSURL.fileURLWithPath("\(photo.id)", relativeToURL: documentsPath)
        
        let fileManager = NSFileManager()
        
        // Download file if it isn't already saved, otherwise retrieve it from disk
        if !fileManager.fileExistsAtPath(filePath.path!) {
            // Show activity indicator on gray background while fetching file from Web
            cell.activityIndicator.hidden = false
            cell.activityIndicator.startAnimating()
            cell.backgroundColor = UIColor.grayColor()
            cell.photoImageView.image = nil
            
            // Download on background thread
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                let url = NSURL(string: photo.urlPath)
                let data = NSData(contentsOfURL: url!)!
                
                // Save the image to disk
                data.writeToFile(filePath.path!, atomically: true)
                
                // Create image
                let image = UIImage(data: data)
                
                // Perform UI updates on main/UI thread
                dispatch_async(dispatch_get_main_queue()) {
                    cell.activityIndicator.stopAnimating()
                    cell.activityIndicator.hidden = true
                    cell.photoImageView.image = image
                }
            }
        } else {
            // Retrieve the image from disk, and display it.
            cell.activityIndicator.hidden = true
            let image = UIImage(contentsOfFile: filePath.path!)
            
            cell.photoImageView.image = image
        }
        
        if let _ = selectedIndexes.indexOf(indexPath) {
            cell.photoImageView.alpha = 0.5
        } else {
            cell.photoImageView.alpha = 1.0
        }
    }
    
    func enableUIAndRemoveActivityIndicator() {
        photoUpdateButton.enabled = true
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    /// This function removes all photos associated with the current pin
    func deleteAllPhotos() {
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            // Delete object from Core Data
            sharedContext.deleteObject(photo)
            
            // Delete photo from disk

            // Build URL
            let documentsPath = CoreDataStackManager.sharedManager.applicationDocumentsDirectory
            let fileURL = NSURL.fileURLWithPath("\(photo.id)", relativeToURL: documentsPath)
            let filePath = fileURL.path!
            
            let fileManager = NSFileManager()
            
            // Delete the file for the image if it exists
            if fileManager.fileExistsAtPath(filePath) {
                do {
                    try fileManager.removeItemAtPath(filePath)
                } catch let error as NSError {
                    print("There was an error removing the file: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateBottomButton() {
        if (selectedIndexes.count > 0) {
            photoUpdateButton.title = "Remove Selected Photos"
        } else {
            photoUpdateButton.title = "New Collection"
        }
    }
    
    
    // MARK: Interface Builder Action Functions
    
    @IBAction func photoUpdateButtonPressed(sender: AnyObject) {
        // Delete existing images
        deleteAllPhotos()
        //Download new images
        downloadFlickrImages()
    }
}


// MARK: Fetched Results Controller Delegate Functions

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        print("in controllerWillChangeContent")
        // TODO: Start out with empty arrays for items to be changed.
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        // TODO: Build out logic for updating changed index arrays in switch statement
        
        switch type {
            
        case .Insert:
            print("Insert an item")
        case .Delete:
            print("Delete an item")
        case .Update:
            print("Update an item")
        case .Move:
            print("Move an item")
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        // TODO: Perform batch updates for each of the change types
        print("in controllerDidChangeContent")
    }
}