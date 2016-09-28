//
//  rangerMapViewController.swift
//  skyQuest
//
//  Created by Gustavo Ferrufino De La Fuente on 9/28/16.
//  Copyright © 2016 itesm. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class rangerMapViewController: UIViewController, MKMapViewDelegate {
   
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
        dropPin(location: CLLocationCoordinate2D(latitude: 25.4064023, longitude: -100.1434737), pinTitle: "Ranger")
        midPoint(c1: locationManager.location!.coordinate, c2: CLLocationCoordinate2D(latitude: 25.4064023, longitude: -100.1434737))
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkLocationAuthorizationStatus() {
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
            centerMapOnLocation(location: locationManager.location!)
            
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 20000, 20000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func dropPin (location: CLLocationCoordinate2D, pinTitle: String) {
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = location
        dropPin.title = pinTitle
        mapView.addAnnotation(dropPin)
    }
    
    func midPoint(c1: CLLocationCoordinate2D, c2: CLLocationCoordinate2D) {
        let midLatitude = (c1.latitude + c2.latitude)/2
        let midLongitude = (c1.longitude + c2.longitude)/2
        
        let midcoordinate = CLLocationCoordinate2D(latitude: midLatitude, longitude: midLongitude)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(midcoordinate, 20000, 20000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func postRangerLocation(){
        let longitude = locationManager.location!.coordinate.longitude
        let latitude = locationManager.location!.coordinate.latitude
        let time = NSDateComponents().hour
        let id = 1  //1 = globo A  2 = globo B 3 = Rangers A 4 = Rangers B
        
        var request = URLRequest(url: URL(string: "http://data.sparkfun.com/input/VGxEGjpqrxHaWvDLNLD6?private_key=9Yd0Y62bndflJdGxAxGY&id=\(id)&lat=\(latitude)&lon=\(longitude)&time=\(time)")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
     //   let postString = ""
       // request.httpBody = postString.data(using: .utf8)
        print(request)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }
        task.resume()
    }
}

