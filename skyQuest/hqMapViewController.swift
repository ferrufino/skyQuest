//
//  hqMapViewController.swift
//  skyQuest
//
//  Created by Jessica M Cavazos Erhard on 9/29/16.
//  Copyright © 2016 itesm. All rights reserved.
//

import UIKit
import MapKit
import MessageUI
import Alamofire

class hqMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate,  MFMessageComposeViewControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendLocationA(_ sender: AnyObject) {
        sendLocationSMS(sender: "1", point: user.pins["Balloon A"]!)
    }
    
    @IBAction func sendLocationB(_ sender: AnyObject) {
        sendLocationSMS(sender: "2", point: user.pins["Balloon B"]!)
    }
    
    //MARK: Sending Message
    /*
     If sender is a Ranger, you use 3 or 4 as id. -> Reciver has to be HQ.
     If sender is HQ, you use 1 or 2 depending on the balloon.
     */
    func sendLocationSMS(sender: String, point: MKPointAnnotation) {
        let messageVC = MFMessageComposeViewController()
        let myUrl = NSURL(string: "SQ://\(point.coordinate.latitude)//\(point.coordinate.longitude)//\(sender)") as! URL
        messageVC.addAttachmentURL(myUrl, withAlternateFilename: "Hello")
        messageVC.body = "SQ://\(point.coordinate.latitude)//\(point.coordinate.longitude)//\(sender)"
        messageVC.recipients = ["8186938092"]
        messageVC.messageComposeDelegate = self
        
        self.present(messageVC, animated: false, completion: nil)
    }

    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        print(result)
        self.dismiss(animated: true, completion: nil)
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
        var sumLatitude = CLLocationDegrees()
        var sumLongitude = CLLocationDegrees()
        if user.pins.count != 1 {
            for pin in user.pins.values {
                sumLatitude += pin.coordinate.latitude
                sumLongitude += pin.coordinate.longitude
            }
            
            let midLat = sumLatitude/Double(user.pins.count + 1)
            let midLon = sumLongitude/Double(user.pins.count + 1)
            
            let midcoordinate = CLLocationCoordinate2D(latitude: midLat, longitude: midLon)
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(midcoordinate, 30000, 30000)
            mapView.setRegion(coordinateRegion, animated: true)
        } else {
            for pin in user.pins.values {
                sumLatitude += pin.coordinate.latitude
                sumLongitude += pin.coordinate.longitude
            }
            let midcoordinate = CLLocationCoordinate2D(latitude: sumLatitude, longitude: sumLongitude)
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(midcoordinate, 30000, 30000)
            mapView.setRegion(coordinateRegion, animated: true)
        }
        
    }
    
    //Get Information for pins
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
                    let latString = newObject["lat"] as! String
                    let lonString = newObject["lon"] as! String
                    let coor = CLLocationCoordinate2D(latitude: Double(latString)!, longitude: Double(lonString)!)
                    
                    //Get the first coordenate of every id.
                    if (newObject["id"] as! String == "1" && !balA){
                        balA = true
                        self.dropPin(location: coor, pinTitle: "BalloonA")
                        print(object as! NSDictionary)
                    } else if (newObject["id"] as! String == "2" && !balB){
                        balB = true
                        self.dropPin(location: coor, pinTitle: "BalloonB")
                        print(object as! NSDictionary)
                    } else if (newObject["id"] as! String == "3" && !raA){
                        raA = true
                        self.dropPin(location: coor, pinTitle: "RangerA")
                        print(object as! NSDictionary)
                    } else if (newObject["id"] as! String == "4" && !raB){
                        raB = true
                        self.dropPin(location: coor, pinTitle: "RangerB")
                        print(object as! NSDictionary)
                    }
                    
                    //If all pins are drop stop searching
                    if (balA && balB && raA && raB){
                        break
                    }
                }
            }
            self.centertoMidPoint()
        }
    }
}


