//
//  ViewController.swift
//  Map
//
//  Created by paul dan on 2019-03-23.
//  Copyright © 2019 paul dan. All rights reserved.
//
import UIKit
import MapKit   //for plain map
import CoreLocation //for users location

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager() //init location manager object
    let regionInMeters:Double  = 10000 //for the zooming in of the region showing the user on the map
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices() //upon loading app trigger that chain of events which will prompt user to allow
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    //this will setup location manager so it can fire off the delegates (extension fxs) written below
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    //this function will actually center in on the users location
    func centerViewOnUserLocation() {   //location is the users location coordiante
        if let location = locationManager.location?.coordinate {    //once we have a location and its not null
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters) //create a region, lat/long = hmuch to zoom in
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    //this will check if the location services are even on in general for the device
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled(){ //its on
            setupLocationManager() //setup location manager using the function we wrote above
            checkLocationAuthorization()
        }
        else {  //alert the user to turn on his location services
            
        }
    }
    
    //helper function to get the location in the center
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    //this function will get the directions from the current users location to where we want
    func getDirections() {
        //locationManager.location? is an optional because sometimes we might not have that, so we write a gaurd statement to prevent against it
        guard let location = locationManager.location?.coordinate else {
            //inform user we don't have their current location
            return
        }
        
        let request = createDirectionsRequest(from: location)
        let directions = MKDirections(request: request)
        
        //now that we have directions object, with the route, we wanna actually calculate it
        directions.calculate {[unowned self] (response, error) in
            //TODO: if error handle that
            guard let response = response else { return }   //guard to make sure we get response back
            
            //else we have a response, which is an array of routes since(requestsAlternateRoutes)
            for route in response.routes {
                self.mapView.addOverlay(route.polyline) //add blue line that follows the route
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)  //resize the view of the map and fit the entire route in the screen
            }
        }
    }
    
    //helper function for creating directions
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
//        let destinationCoordinate       = getCenterLocation(for: mapView).coordinate
        let destinationCoordinate       = CLLocationCoordinate2D(latitude: 51.0426, longitude: -114.0776)   //hard coded to the STUFF store lol
        let startingLocation            = MKPlacemark(coordinate: coordinate)
        let destination                 = MKPlacemark(coordinate: destinationCoordinate)
        
        let request                     = MKDirections.Request()
        request.source                  = MKMapItem(placemark: startingLocation)
        request.destination             = MKMapItem(placemark: destination)
        request.transportType           = .automobile   //hard coding that were in a car
        request.requestsAlternateRoutes = false
        
        return request
    }
    
    @IBAction func goButtonTapped(_ sender: UIButton) {
        getDirections() //when user taps button, then go get those directions
    }
    
 
    //this function will check if the user gives location permission to our specific app
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus(){
        case .authorizedWhenInUse:  //when app is open, that's only time when app can get users loc services
            mapView.showsUserLocation = true //this will show the little blue dot representing the user
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()  //update the users view as he moves from the delegate we wrote below
        case .denied:   //they denied the permission
            //show alert instructing how to turn on permissions
            break
        case .notDetermined: //haven't picked allow or not allow
            locationManager.requestWhenInUseAuthorization() //if not determined, ask permission
            break
        case .restricted:   //user cannot change app status (parental controls)
            //show alert letting them know its restricted
            break
        case .authorizedAlways: //app can get location while in background too, probs use this for our app
            break
        }
    }
    
}


extension ViewController: CLLocationManagerDelegate {
    
    //everytime the location is updated, didupdatelocations fires off an arrary of the users location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return } //guard against their being no location, if null don't execute whats below
        let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude) //get lat/long of location that's the center
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    //when the authorization changes we want to just recheck that we have the correct authorizations with the app, so even if they hit allow at the start then do this
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        
        return renderer
    }
    
}
