//
//  ViewController.swift
//  OfflineMapDownload in swift
//
//  Created by PC on 24/01/19.
//  Copyright © 2019 PC. All rights reserved.
//

import UIKit
import Mapbox

// MGLPointAnnotation subclass
class MyCustomPointAnnotation: MGLPointAnnotation {
    var willUseImage: Bool = false
}


class ViewController: UIViewController, MGLMapViewDelegate  {

    var mapView: MGLMapView!
    var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "mapbox://styles/mapbox/streets-v11")
        mapView = MGLMapView(frame: view.bounds, styleURL: url)
        
    //    mapView = MGLMapView(frame: view.bounds, styleURL: MGLStyle.darkStyleURL)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.tintColor = .gray
        mapView.delegate = self
        self.view.addSubview(mapView)
        
        mapView.setCenter(CLLocationCoordinate2D(latitude: 21.214503, longitude: 72.886904),
                          zoomLevel: 13, animated: false)
        
        mapView.showsUserLocation = true
        
        // Add a point annotation
        let annotation = MGLPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 21.216219, longitude: 72.881345)
        annotation.title = "Central Park"
        annotation.subtitle = "The biggest park in New York City!The biggest park in New York City!The biggest park in New York City!The biggest park in New York City!The biggest park in New York City!The biggest park in New York City!The biggest park in New York City!"
        mapView.addAnnotation(annotation)

        let annotation1 = MGLPointAnnotation()
        annotation1.coordinate = CLLocationCoordinate2D(latitude: 21.211296, longitude: 72.868832)
        annotation1.title = "Central Park"
        annotation1.subtitle = "The biggest park in Surat City!"
        mapView.addAnnotation(annotation1)

        let annotation2 = MGLPointAnnotation()
        annotation2.coordinate = CLLocationCoordinate2D(latitude: 21.206735, longitude: 72.857593)
        annotation2.title = "Central Park"
        annotation2.subtitle = "The biggest park in Surat City!"
        mapView.addAnnotation(annotation2)

        let annotation3 = MGLPointAnnotation()
        annotation3.coordinate = CLLocationCoordinate2D(latitude: 21.197849, longitude: 72.859172)
        annotation3.title = "Central Park"
        annotation3.subtitle = "The biggest park in Surat City!"
        mapView.addAnnotation(annotation3)

        let annotation4 = MGLPointAnnotation()
        annotation4.coordinate = CLLocationCoordinate2D(latitude: 21.252254, longitude: 72.856605)
        annotation4.title = "Central Park"
        annotation4.subtitle = "The biggest park in Surat City!"
        mapView.addAnnotation(annotation4)

        let annotation5 = MGLPointAnnotation()
        annotation5.coordinate = CLLocationCoordinate2D(latitude: 21.213085, longitude: 72.776939)
        annotation5.title = "Central Park"
        annotation5.subtitle = "The biggest park in Surat City!"
        mapView.addAnnotation(annotation5)
//        let pointA = MyCustomPointAnnotation()
//        pointA.coordinate = CLLocationCoordinate2D(latitude: 21.198299, longitude: 72.774323)
//        pointA.title = "Stovepipe Wells"
//        pointA.willUseImage = true
//
//        let pointB = MyCustomPointAnnotation()
//        pointB.coordinate = CLLocationCoordinate2D(latitude: 21.186135, longitude: 72.746869)
//        pointB.title = "Furnace Creek"
//        pointB.willUseImage = true
        
        let myPlaces = [annotation, annotation1, annotation2, annotation3, annotation4, annotation5]
//        let myPlaces = [pointA, pointB]
        
        
        
        
        
        // Setup offline pack notification handlers.
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackProgressDidChange), name: NSNotification.Name.MGLOfflinePackProgressChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackDidReceiveError), name: NSNotification.Name.MGLOfflinePackError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackDidReceiveMaximumAllowedMapboxTiles), name: NSNotification.Name.MGLOfflinePackMaximumMapboxTilesReached, object: nil)
        
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped.
        return true
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        let camera = MGLMapCamera(lookingAtCenter: annotation.coordinate, fromDistance: 4500, pitch: 15, heading: 180)
        mapView.fly(to: camera, withDuration: 4,
                    peakAltitude: 3000, completionHandler: nil)
    }
    
//    //show dot as pin
//    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
//
//        if let castAnnotation = annotation as? MyCustomPointAnnotation {
//            if (castAnnotation.willUseImage) {
//                return nil
//            }
//        }
//
//        // Assign a reuse identifier to be used by both of the annotation views, taking advantage of their similarities.
//        let reuseIdentifier = "reusableDotView"
//
//        // For better performance, always try to reuse existing annotations.
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
//
//        // If there’s no reusable annotation view available, initialize a new one.
//        if annotationView == nil {
//            annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
//            annotationView?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//            annotationView?.layer.cornerRadius = (annotationView?.frame.size.width)! / 2
//            annotationView?.layer.borderWidth = 4.0
//            annotationView?.layer.borderColor = UIColor.white.cgColor
//            annotationView!.backgroundColor = UIColor(red: 0.03, green: 0.80, blue: 0.69, alpha: 1.0)
//        }
//
//        return annotationView
//    }

    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        // Start downloading tiles and resources for z13-16.
        startOfflinePackDownload()
    }
    
    deinit {
        // Remove offline pack observers.
        NotificationCenter.default.removeObserver(self)
    }
    
    func startOfflinePackDownload() {
        // Create a region that includes the current viewport and any tiles needed to view it when zoomed further in.
        // Because tile count grows exponentially with the maximum zoom level, you should be conservative with your `toZoomLevel` setting.
        let region = MGLTilePyramidOfflineRegion(styleURL: mapView.styleURL, bounds: mapView.visibleCoordinateBounds, fromZoomLevel: mapView.zoomLevel, toZoomLevel: 20)
        
        // Store some data for identification purposes alongside the downloaded resources.
        let userInfo = ["name": "My Offline Pack"]
        let context = NSKeyedArchiver.archivedData(withRootObject: userInfo)
        
        // Create and register an offline pack with the shared offline storage object.
        
        MGLOfflineStorage.shared.addPack(for: region, withContext: context) { (pack, error) in
            guard error == nil else {
                // The pack couldn’t be created for some reason.
                print("Error: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            
            // Start downloading.
            pack!.resume()
        }
        
    }
    
    // MARK: - MGLOfflinePack notification handlers
    
    @objc func offlinePackProgressDidChange(notification: NSNotification) {
        // Get the offline pack this notification is regarding,
        // and the associated user info for the pack; in this case, `name = My Offline Pack`
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String] {
            let progress = pack.progress
            // or notification.userInfo![MGLOfflinePackProgressUserInfoKey]!.MGLOfflinePackProgressValue
            let completedResources = progress.countOfResourcesCompleted
            let expectedResources = progress.countOfResourcesExpected
            
            // Calculate current progress percentage.
            let progressPercentage = Float(completedResources) / Float(expectedResources)
            
            // Setup the progress bar.
            if progressView == nil {
                progressView = UIProgressView(progressViewStyle: .default)
                let frame = view.bounds.size
                progressView.frame = CGRect(x: frame.width / 4, y: frame.height * 0.75, width: frame.width / 2, height: 10)
                view.addSubview(progressView)
            }
            
            progressView.progress = progressPercentage
            
            // If this pack has finished, print its size and resource count.
            if completedResources == expectedResources {
                let byteCount = ByteCountFormatter.string(fromByteCount: Int64(pack.progress.countOfBytesCompleted), countStyle: ByteCountFormatter.CountStyle.memory)
                print("Offline pack “\(userInfo["name"] ?? "unknown")” completed: \(byteCount), \(completedResources) resources")
                progressView.isHidden = true
            } else {
                // Otherwise, print download/verification progress.
                print("Offline pack “\(userInfo["name"] ?? "unknown")” has \(completedResources) of \(expectedResources) resources — \(progressPercentage * 100)%.")
            }
        }
    }
    
    @objc func offlinePackDidReceiveError(notification: NSNotification) {
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String],
            let error = notification.userInfo?[MGLOfflinePackUserInfoKey.error] as? NSError {
            print("Offline pack “\(userInfo["name"] ?? "unknown")” received error: \(error.localizedFailureReason ?? "unknown error")")
        }
    }
    
    @objc func offlinePackDidReceiveMaximumAllowedMapboxTiles(notification: NSNotification) {
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String],
            let maximumCount = (notification.userInfo?[MGLOfflinePackUserInfoKey.maximumCount] as AnyObject).uint64Value {
            print("Offline pack “\(userInfo["name"] ?? "unknown")” reached limit of \(maximumCount) tiles.")
        }
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

