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
    
    @IBAction func centerMap(_ sender: AnyObject) {
        centerMapOnLocation(location: locationManager.location!)
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
            getData()
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
    func dropPin (location: CLLocationCoordinate2D, pinTitle: String, imgTitle: String) {
        let dropPin = CustomAnnotation()
        dropPin.coordinate = location
        dropPin.title = pinTitle
        dropPin.imageName = imgTitle
        let anotation = dropPin as! MKAnnotation
        
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
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(midcoordinate, 60000, 60000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "demo")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "demo")
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        annotationView!.image = UIImage(named: "image")
        
        return annotationView
    }
    
    //Post Ranger location
    func postRangerLocation() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ssZ'T'dd-MM-yyyy"
        let longitude = locationManager.location!.coordinate.longitude
        let latitude = locationManager.location!.coordinate.latitude
        let id = user.id!  //1 = globo A  2 = globo B 3 = Rangers A 4 = Rangers B
        let time = date
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
        
        Alamofire.request("http:data.sparkfun.com/input/VGxEGjpqrxHaWvDLNLD6.json", method: .post, parameters: parameters, headers: headers).responseJSON{ response in
            print(response.description)
        }
    }
    
    //Get Information for pins
    func getData(){
        let todoEndpoint: String = "http://data.sparkfun.com/output/VGxEGjpqrxHaWvDLNLD6.json"
        Alamofire.request(todoEndpoint).responseJSON { response in
            //to get JSON return value
            if let result = response.result.value {
                var balA = false, balB = false
                let JSON = result as! NSArray
                
                //For every object in the response
                for object in JSON{
                    let newObject = object as! NSDictionary //Cast AnyObject to NSDictionary
                    
                    //Create Coordenates with data
                    let latString = (newObject["lat"] as! String).components(separatedBy: " ")
                    let lonString = (newObject["lon"] as! String).components(separatedBy: " ")
                    let coor = CLLocationCoordinate2D(latitude: Double(latString[0])!, longitude: Double(lonString[0])!)
                    
                    //Get the first coordenate of every id.
                    if (newObject["id"] as! String == "1" && !balA){
                        balA = true
                        self.dropPin(location: coor, pinTitle: "BalloonA", imgTitle: "balloon-icon")
                        print(object as! NSDictionary)
                    } else if (newObject["id"] as! String == "2" && !balB){
                        balB = true
                        self.dropPin(location: coor, pinTitle: "BalloonB", imgTitle: "balloon-icon")
                        print(object as! NSDictionary)
                    }
                    
                    //If all pins are drop stop searching
                    if (balA && balB){
                        break
                    }
                }
            }
            self.centertoMidPoint()
        }
    }

}

