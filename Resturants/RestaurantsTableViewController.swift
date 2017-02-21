//
//  ResturantsTableViewController.swift
//  Resturants
//
//  Created by Toleen Jaradat on 2/6/17.
//  Copyright © 2017 Toleen Jaradat. All rights reserved.
//

import UIKit
import CoreLocation

class RestaurantsTableViewController: UITableViewController,CLLocationManagerDelegate {

    var restaurants = [Restaurant]()
    var locationManager: CLLocationManager!
    var userLat = CLLocationDegrees()
    var userLong = CLLocationDegrees()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
        addGeoLocation()
        downloadRestaurants()
    }
    
    func addGeoLocation(){
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
       
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        userLat = (self.locationManager.location?.coordinate.latitude)!
        userLong = (self.locationManager.location?.coordinate.longitude)!
        
     }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return restaurants.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCellID", for: indexPath)
        
        let restaurant = restaurants[indexPath.row]

        cell.textLabel?.text = "\(restaurant.name!)"
        cell.detailTextLabel?.text = displayPriceLevel(price: restaurant.priceLevel!)
        
        //cell.detailTextLabel?.text = distanceInMiles
        return cell
    }
    
    func displayPriceLevel(price: Int) -> String {

        switch price {
            
        case 0:
            return "free"
        case 1:
            return "$"
        case 2:
            return "$$"
        case 3:
            return "$$$"
        case 4:
            return "$$$$"
            
        default:
           return ""
        }
        
    }

    
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ToDetailVC" {
            let destinationVC = segue.destination as! DetailViewController
            let index = tableView.indexPathForSelectedRow?.row
            destinationVC.restaurant = self.restaurants[index!]
            
        }

    }

    
        
fileprivate func downloadRestaurants() {
    
    // TIY lat,long : 29.735132,-95.390612
    
    let restaurantsAPI = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(userLat),\(userLong)&radius=2500&type=restaurant&keyword=cruise&key=AIzaSyD_4JlfHkMe8fdl_tVo9eCrVCT7NnIvaLw"
   
            
    guard let url = URL(string: restaurantsAPI) else {
        fatalError("Invalid URL")
    }
    
    let session = URLSession.shared
    
    session.dataTask(with: url, completionHandler: { (data: Data?, response: URLResponse?,err: Error?) in
        
                            //results --> array of dictionaries for resaurants
                            let jsonRestaurantsDictionary = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary //{
                    
                            let jsonRestaurantsArray = jsonRestaurantsDictionary.value(forKey: "results") as! [AnyObject]
                    
                            for place in jsonRestaurantsArray {
                                
                                let restaurant = Restaurant()
                                
                                
                                let geo = place.value(forKey: "geometry") as! NSDictionary
                                let loc = geo["location"] as! NSDictionary
                                
                                restaurant.lat = loc.value(forKey:"lat") as? Double
                                restaurant.long = loc.value(forKey:"lng") as? Double
                                
                                restaurant.name = place.value(forKey:"name") as? String
                                restaurant.address = place.value(forKey:"vicinity") as? String
                                
                                if let openningHours = place.value(forKey:"opening_hours") as? NSDictionary {
                                    
                                restaurant.openNow = openningHours.value(forKey:"open_now") as? Bool
                                    
                                }
                                
                                restaurant.rating = place.value(forKey:"rating") as? Int ?? 0
                                
                                // price level is optional, return zero if it doesn't has a value
                                restaurant.priceLevel  = place.value(forKey:"price_level") as? Int ?? 10
                                
                            self.restaurants.append(restaurant)
                                
                            }
                    
                           //print(jsonRestaurantsArray)
                            
        // Update UI
        
        DispatchQueue.main.async(execute: {
            
            self.tableView.reloadData()
            
        })
        
        } ) .resume() //end of the task
    
    }
    
}
    

