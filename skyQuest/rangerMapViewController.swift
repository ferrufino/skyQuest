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
import MessageUI
import Alamofire

class rangerMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate,  MFMessageComposeViewControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var myId = "3"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
        
        locationManager.startUpdatingLocation() //Continue updating map
        
        //getLocations()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Sending Message
    @IBAction func SendLocationSMS(_ sender: AnyObject) {
        let messageVC = MFMessageComposeViewController()
        let myUrl = NSURL(string: "SQ://\(myId)//\(locationManager.location!.coordinate.latitude)//\(locationManager.location!.coordinate.longitude)") as! URL
        messageVC.addAttachmentURL(myUrl, withAlternateFilename: "HEllo")
        messageVC.body = "SQ://\(myId)//\(locationManager.location!.coordinate.latitude)//\(locationManager.location!.coordinate.longitude)"
        messageVC.recipients = ["8186938092"]
        messageVC.messageComposeDelegate = self
        
        self.present(messageVC, animated: false, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        print(result)
        self.dismiss(animated: true, completion: nil)
    }
    
    //Location Authorization
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
            centerMapOnLocation(location: locationManager.location!)
            dropPin(location: CLLocationCoordinate2D(latitude: 25.4064023, longitude: -100.1434737), pinTitle: "Ranger")
            centerMidPoint(c1: locationManager.location!.coordinate, c2: CLLocationCoordinate2D(latitude: 25.4064023, longitude: -100.1434737))
            postRangerLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    //Update Location of user & change the zoom.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        centerMidPoint(c1: locationManager.location!.coordinate, c2: CLLocationCoordinate2D(latitude: 25.4064023, longitude: -100.1434737))
        print("Updated Ranger Location")
        postRangerLocation()
        print("Ranger Location Uploaded")
    }
    
    //Center the map on Ranger location
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 20000, 20000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //Drop pin
    func dropPin (location: CLLocationCoordinate2D, pinTitle: String) {
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = location
        dropPin.title = pinTitle
        mapView.addAnnotation(dropPin)
    }
    
    //Center between 2 points
    func centerMidPoint(c1: CLLocationCoordinate2D, c2: CLLocationCoordinate2D) {
        let midLatitude = (c1.latitude + c2.latitude)/2
        let midLongitude = (c1.longitude + c2.longitude)/2
        
        let midcoordinate = CLLocationCoordinate2D(latitude: midLatitude, longitude: midLongitude)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(midcoordinate, 20000, 20000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //Post Ranger location
    func postRangerLocation() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let longitude = locationManager.location!.coordinate.longitude
        let latitude = locationManager.location!.coordinate.latitude
        let id = 2  //1 = globo A  2 = globo B 3 = Rangers A 4 = Rangers B
        
        print("lat: \(latitude) long:\(longitude) timestamp:\(date)")
        
        let headers = [
            "Phant-Private-Key":"9Yd0Y62bndflJdGxAxGY"
        ]
        
        let parameters = [
            "id" : "\(id)",
            "lat": "\(latitude)",
            "lon": "\(longitude)",
            "timestamp": "\(date)"
        ]
        
        Alamofire.request("http:data.sparkfun.com/input/VGxEGjpqrxHaWvDLNLD6?.json", method: .post, parameters: parameters, headers: headers).responseJSON{ response in
            print(response.description)
        }
    }

}

