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
        let anotation = dropPin as! CustomAnnotation
        mapView.addAnnotation(dropPin)
        user.pins[pinTitle] = dropPin
    }
    
    //Center between x points
    func centertoMidPoint() {
        if mapView.annotations.count == 0 {
            return
        }
        var topLeftCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        topLeftCoord.latitude = -90
        topLeftCoord.longitude = 180
        var bottomRightCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        bottomRightCoord.latitude = 90
        bottomRightCoord.longitude = -180
        for annotation: MKAnnotation in mapView.annotations {
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude)
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude)
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude)
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude)
        }
        
        var region: MKCoordinateRegion = MKCoordinateRegion()
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.4
        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.4
        region = mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
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
    

    
    func getData(){
        let todoEndpoint: String = "http://data.sparkfun.com/output/VGxEGjpqrxHaWvDLNLD6.json"
        Alamofire.request(todoEndpoint).responseJSON { response in
            //to get JSON return value
            if let result = response.result.value {
                var balA = false, balB = false, raA = false , raB = false
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

                        if user.pins["BalloonA"] == nil {
                            self.dropPin(location: coor, pinTitle: "BalloonA", imgTitle: "balloon-icon")
                        } else if user.pins["BalloonA"]?.coordinate.latitude != coor.latitude ||  user.pins["BalloonA"]?.coordinate.longitude != coor.longitude{
                            user.changepinLocation(pinTitle: "BalloonA", lat: "\(coor.latitude)", lon: "\(coor.longitude)")
                        }
                        print(object as! NSDictionary)
                    } else if (newObject["id"] as! String == "2" && !balB){
                        balB = true
                        if user.pins["BalloonB"] == nil {
                            self.dropPin(location: coor, pinTitle: "BalloonB", imgTitle: "balloon-icon")
                        } else if user.pins["BalloonA"]?.coordinate.latitude != coor.latitude ||  user.pins["BalloonB"]?.coordinate.longitude != coor.longitude{
                            user.changepinLocation(pinTitle: "BalloonB", lat: "\(coor.latitude)", lon: "\(coor.longitude)")
                        }
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

