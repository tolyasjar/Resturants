//
//  ViewController.swift
//  Resturants
//
//  Created by Toleen Jaradat on 2/6/17.
//  Copyright © 2017 Toleen Jaradat. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DetailViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var restNameLbl: UILabel!
    
    @IBOutlet weak var restOpenLbl: UILabel!
    
    @IBOutlet weak var restRatingLbl: UILabel!
    
    @IBOutlet weak var restDistLbl: UILabel!
    
    var locationManager: CLLocationManager! = CLLocationManager()
    var restaurant = Restaurant()
    
    var userLat = CLLocationDegrees()
    var userLong = CLLocationDegrees()
    var userLocation = CLLocation()
    var distanceInMiles = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = restaurant.name
        
        self.restNameLbl.text = restaurant.name
        self.restDistLbl.text = "Distance"
        
                displayRating(rating: restaurant.rating!)
        displayOpenNow(openNow: restaurant.openNow!)
        
        addGeoLocation()
        addMap()
    }
    
    //draw the path overlay
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
         return renderer
    }
    
    func addGeoLocation(){
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        map.showsUserLocation = true
        
        userLat = (self.locationManager.location?.coordinate.latitude)!
        userLong = (self.locationManager.location?.coordinate.longitude)!
        
        // Calculate Distance & update the UI
        
        let restLoc = CLLocation(latitude: restaurant.lat!, longitude: restaurant.long!)
        userLocation = CLLocation(latitude: userLat, longitude: userLong)
        distanceInMiles = String(format:"%.2f",userLocation.distance(from: restLoc) * 0.000621371) // in miles
        self.restDistLbl.text = self.distanceInMiles + " Miles"
        
        //To find the route between 2 placemarks
        //placemark
        let startPlacemark = MKPlacemark(coordinate: userLocation.coordinate, addressDictionary: nil)
        let destPlacemark = MKPlacemark(coordinate: restLoc.coordinate, addressDictionary: nil)
        
        //set the delegate
        self.map.delegate = self // to add the overlay to the map

        
        //request
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: startPlacemark)
        request.destination = MKMapItem(placemark: destPlacemark)
        request.requestsAlternateRoutes = false
        request.transportType = .automobile
        
        let direction = MKDirections(request: request)
        direction.calculate(completionHandler: { (response, err) in
        
            if err == nil {
                for route in response!.routes {
                    self.map.add(route.polyline)
                }
            } else {
            print("err")
                
            }
        })
    }
    
    func displayOpenNow(openNow: Bool){
        
        if (openNow){
            
            self.restOpenLbl.textColor = UIColor.green
            self.restOpenLbl.text = "Open"
            
        } else {
            
            self.restOpenLbl.textColor = UIColor.red
            self.restOpenLbl.text = "Close"
        }

    }
    
    func displayRating(rating: Int) {

        switch rating {
            
        case 1:
            self.restRatingLbl.text = "⭐️"
        case 2:
            self.restRatingLbl.text = "⭐️⭐️"
        case 3:
            self.restRatingLbl.text = "⭐️⭐️⭐️"
        case 4:
            self.restRatingLbl.text = "⭐️⭐️⭐️⭐️"
        case 5:
            self.restRatingLbl.text = "⭐️⭐️⭐️⭐️⭐️"
        default:
            self.restRatingLbl.text = "⭐️"
        }
        
    }
    
    
    func addMap(){
        
        let latitude = restaurant.lat
        let longitude = restaurant.long
        
        //focus the region
        
        let span = MKCoordinateSpanMake(0.03, 0.03)
        let location = CLLocationCoordinate2DMake(latitude!, longitude!)
        let region = MKCoordinateRegionMake(location, span)
        
        map.setRegion(region, animated: true)
        
        // Add restaurant annotaion to map
        
        let pinAnnotation = MKPointAnnotation()
        pinAnnotation.coordinate = location
        pinAnnotation.title = restaurant.name
        pinAnnotation.subtitle = restaurant.address
        
        self.map.addAnnotation(pinAnnotation)

    }

}

