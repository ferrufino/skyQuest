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
    var myId = " 1"
    
    
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
    /*
     If sender is a Ranger, you use 3 or 4 as id. -> Reciver has to be HQ.
     If sender is HQ, you use 1 or 2 depending on the balloon.
     */
    @IBAction func SendLocationSMS(_ sender: AnyObject) {
        let messageVC = MFMessageComposeViewController()
        let myUrl = NSURL(string: "SQ://\(locationManager.location!.coordinate.latitude)//\(locationManager.location!.coordinate.longitude)//\(user.id!)") as! URL
        messageVC.addAttachmentURL(myUrl, withAlternateFilename: "Hello")
        messageVC.body = "SQ://\(locationManager.location!.coordinate.latitude)//\(locationManager.location!.coordinate.longitude)//\(user.id!)"
        messageVC.recipients = ["8186938092"]
        messageVC.messageComposeDelegate = self
        
        self.present(messageVC, animated: false, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        if result == MessageComposeResult.cancelled{
            print("Message cancelled")
        } else if result == MessageComposeResult.sent {
            print("Message sent")
        } else {
            print("Message failed")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    //Location Authorization
    /*
     Get Authorization
     Droppin for balloons
     Center to mid point
    */
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
            centerMapOnLocation(location: locationManager.location!)
            dropPin(location: CLLocationCoordinate2D(latitude: 25.4064023, longitude: -100.1434737), pinTitle: "RangerA")
            dropPin(location: CLLocationCoordinate2D(latitude: 25.4065023, longitude: -100.1534737), pinTitle: "RangerB")
            centertoMidPoint()
            postRangerLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func updateMap(){
        
    }
    
    //Update Location of user & change the zoom.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        centertoMidPoint()
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
        user.pins[pinTitle] = dropPin
    }
    
    //Center between x points
    func centertoMidPoint() {
        var sumLatitude = locationManager.location?.coordinate.latitude
        var sumLongitude = locationManager.location?.coordinate.longitude
        
        for pin in user.pins.values {
            sumLatitude! += pin.coordinate.latitude
            sumLongitude! += pin.coordinate.longitude
        }
        
        let midLat = sumLatitude!/Double(user.pins.count + 1)
        let midLon = sumLongitude!/Double(user.pins.count + 1)
        
        let midcoordinate = CLLocationCoordinate2D(latitude: midLat, longitude: midLon)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(midcoordinate, 30000, 30000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //Post Ranger location
    func postRangerLocation() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let longitude = locationManager.location!.coordinate.longitude
        let latitude = locationManager.location!.coordinate.latitude
        let id = 9  //1 = globo A  2 = globo B 3 = Rangers A 4 = Rangers B
        let time = "99999"
        print("lat: \(latitude) long:\(longitude) timestamp:\(date) time:\(time)")
        
        let headers = [
            "Phant-Private-Key":"9Yd0Y62bndflJdGxAxGY"
        ]
        
        let parameters: Parameters = [
            "id" : "\(id)",
            "lat": "\(latitude)",
            "lon": "\(longitude)",
            "time": "\(time)"
        ]
        
        Alamofire.request("http:data.sparkfun.com/input/VGxEGjpqrxHaWvDLNLD6?.json", method: .post, parameters: parameters, headers: headers).responseJSON{ response in
            print(response.description)
        }    }
    
    //Get information for pins
    func getData(){
        
    }

}

