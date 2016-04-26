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
                //TODO: Retrieve existing photos
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
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.removeFromSuperview()
                        return
                    }
                    
                    guard let photoArray = photos else {
                        print("Error accessing photos.")
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.removeFromSuperview()
                        return
                    }
                    
                    for photo in photoArray {
                        let photoObject = Photo(path: photo)
                        pin.photos.append(photoObject)
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.photoCollectionView.reloadData()
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.removeFromSuperview()
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
        return pin.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = photoCollectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        let photoURL = pin.photos[indexPath.row]
        
        let url = NSURL(string: photoURL.urlPath)
        let data = NSData(contentsOfURL: url!)
        cell.photoImageView.image = UIImage(data: data!)
        
        return cell
    }
}