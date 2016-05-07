//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Joshua Hunsberger on 4/19/16.
//  Copyright © 2016 Joshua Hunsberger. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: Properties
    var pin: Pin!
    let activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0,50,50))
    var retrievedPhotos = [Photo]()
    
    // MARK: InterfaceBuilder outlet properties
    
    @IBOutlet weak var pinMapView: MKMapView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var photoUpdateButton: UIButton!
    
    // MARK: View lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        
        if let pin = pin {
            pinMapView.showAnnotations([pin.annotation], animated: true)
            
            if pin.photos.count != 0 {
                for photo in pin.photos {
                    retrievedPhotos.append(photo)
                }
            } else {
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
                        self.retrievedPhotos.append(photo)
                        pin.photos.append(photo)
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.photoCollectionView.reloadData()
                        self.enableUIAndRemoveActivityIndicator()
                    }
                }
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
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return retrievedPhotos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = photoCollectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        let photo = retrievedPhotos[indexPath.row]
        
        // Build URL
        let documentsPath = CoreDataStackManager.sharedManager.applicationDocumentsDirectory
        let filePath = NSURL.fileURLWithPath("\(photo.flickrID)", relativeToURL: documentsPath)
        
        let fileManager = NSFileManager()
        
        // Download file if it isn't already saved, otherwise retrieve it from disk
        if !fileManager.fileExistsAtPath(filePath.path!) {
            // Show activity indicator on gray background while fetching file from Web
            cell.activityIndicator.hidden = false
            cell.activityIndicator.startAnimating()
            cell.backgroundColor = UIColor.grayColor()
            
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
        
        return cell
    }
    
    func enableUIAndRemoveActivityIndicator() {
        photoUpdateButton.enabled = true
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
}