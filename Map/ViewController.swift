//
//  ViewController.swift
//  Map
//
//  Created by paul dan on 2019-03-23.
//  Copyright © 2019 paul dan. All rights reserved.
//
import GoogleMaps
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func loadView() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate is downtown calgary for now at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: 51.0478, longitude: -114.0593, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        self.view = mapView
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 51.0478, longitude: -114.0593)
        marker.title = "DownTown Calgary"
        marker.snippet = "Alberta"
        marker.map = mapView
    }


}

