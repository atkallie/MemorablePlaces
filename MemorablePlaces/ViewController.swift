//
//  ViewController.swift
//  MemorablePlaces
//
//  Created by Ahmed T Khalil on 1/20/17.
//  Copyright © 2017 kalikans. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    //view of the map
    @IBOutlet var map: MKMapView!
    
    //manager for user location
    var locationManager = CLLocationManager()
    
    //initialize at some arbitrary non-sensical latitude and longitude
    var latRecovered : CLLocationDegrees = -200
    var lonRecovered: CLLocationDegrees = -200
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //optional: set initial map view to where the user currently is
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        //create the desired region depending on whether the user clicked on something or not
        if latRecovered != -200 {
            let latDelta : CLLocationDegrees = 0.05
            let lonDelta : CLLocationDegrees = 0.05
            let mapSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            
            let loc = CLLocationCoordinate2D(latitude: latRecovered, longitude: lonRecovered)
            let region = MKCoordinateRegion(center: loc, span: mapSpan)
            //then set the region on your map's view (recognize that this is just data and the map view is a visualization of this data)
            map.setRegion(region, animated: true)
            
            //then reset the values for the next iteration
            latRecovered = -200
            lonRecovered = -200
        }else {
            locationManager.startUpdatingLocation()
            //then go get the location using the 'didUpdateLocations' function below and set it to the initial region
        }
        
        //First create a UILongPressGestureRecognizer object. This tells us which new location the user wishes to store
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(longpress(gestureRecognizer:)))
        
        //set the time for the long press
        uilpgr.minimumPressDuration = 2
        
        //then add it to your map
        map.addGestureRecognizer(uilpgr)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //creating a span for our map's view
        let latDelta : CLLocationDegrees = 0.05
        let lonDelta : CLLocationDegrees = 0.05
        let mapSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        
        let region = MKCoordinateRegion(center: locations[0].coordinate, span: mapSpan)
        //then set the region on your map's view (recognize that this is just data and the map view is visualization of this data)
        map.setRegion(region, animated: true)
    }
    
    //this is what happens when there is a long press
    func longpress(gestureRecognizer: UIGestureRecognizer){
        
        //this is the CGPoint where the user touched relative to the map
        let touchPoint = gestureRecognizer.location(in: self.map)
        
        //convert the CGPoint to coordinates on the map
        let locCoordinate = map.convert(touchPoint, toCoordinateFrom: self.map)
        let location = CLLocation(latitude: locCoordinate.latitude, longitude: locCoordinate.longitude)
        
        
        var address: String = ""
        //reverse geocode
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if error != nil{
                print(error as Any)
            }else{
                if let placemark = placemarks?[0]{
                    //street number
                    var subthoroughfare = ""
                    if placemark.subThoroughfare != nil{
                        subthoroughfare = placemark.subThoroughfare!
                        address += subthoroughfare
                    }
                    //street name
                    var thoroughfare = ""
                    if placemark.thoroughfare != nil{
                        thoroughfare = placemark.thoroughfare!
                        if address == "" {
                            address += thoroughfare
                        }else{
                            address += " \(thoroughfare)"
                        }
                    }
                    
                    //if no address found, try to see if there are any other associated labels
                    if address.replacingOccurrences(of: " ", with: "") == "" {
                        if placemark.inlandWater != nil{
                            address = placemark.inlandWater!
                        }else if placemark.ocean != nil{
                            address = placemark.ocean!
                        }else if placemark.name != nil {
                            address = placemark.name!
                        }else if placemark.locality != nil{
                            address = placemark.locality!
                        }
                    }
                    
                    //if there is a name, then add an annotation and store it, otherwise don't
                    if address.replacingOccurrences(of: " ", with: "") != "" {
                        //add an annotation as per the usual protocol
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = locCoordinate
                        annotation.title = address
                        self.map.addAnnotation(annotation)
                        
                        //first retrieve from permanent storage (might be nothing there)
                        var placesStr : [String]
                        let placesStrObj = UserDefaults.standard.object(forKey: "placesStrFinal")
                        
                        //String array of places
                        //check if there are previous places; if not initialize a new array
                        if let tempPlacesStr = placesStrObj as? [String] {
                            placesStr = tempPlacesStr
                            placesStr.append(address)
                        }else{
                            placesStr = [address]
                        }
                        
                        //update permanent storage for given key
                        UserDefaults.standard.set(placesStr, forKey: "placesStrFinal")
                        
                        
                        //String array of coordinates for places
                        var placesCoor : [String]
                        let placesCoorObj = UserDefaults.standard.object(forKey: "placesCoorFinal")
                         
                        //CLLocationCoordinate2D array of coordinates for marked places
                        //check if there are previous places; if not initialize a new array
                        if let tempPlacesCoor = placesCoorObj as? [String] {
                            placesCoor = tempPlacesCoor
                            let strCoordinate = String(locCoordinate.latitude)+","+String(locCoordinate.longitude)
                            placesCoor.append(strCoordinate)
                        }else{
                            let strCoordinate = String(locCoordinate.latitude)+","+String(locCoordinate.longitude)
                            placesCoor = [strCoordinate]
                        }
 
                        UserDefaults.standard.set(placesCoor, forKey: "placesCoorFinal")
                        
                        print("Places Strings After Adding: \(placesStr)")
                        print("Places Coordinates After Adding: \(placesCoor)")
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

