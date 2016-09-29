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
        let myUrl = NSURL(string: "SQ://-//\(sender)//\(point.coordinate.latitude)//\(point.coordinate.longitude)") as! URL
        messageVC.addAttachmentURL(myUrl, withAlternateFilename: "Hello")
        messageVC.body = "SQ://-//\(sender)//\(point.coordinate.latitude)//\(point.coordinate.longitude)"
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
    
    //Center between 2 points
    func centerMidPoint(c1: CLLocationCoordinate2D, c2: CLLocationCoordinate2D) {
        let midLatitude = (c1.latitude + c2.latitude)/2
        let midLongitude = (c1.longitude + c2.longitude)/2
        
        let midcoordinate = CLLocationCoordinate2D(latitude: midLatitude, longitude: midLongitude)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(midcoordinate, 20000, 20000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //Get Infromation for pins
    func getData(){
        let todoEndpoint: String = "http://data.sparkfun.com/output/VGxEGjpqrxHaWvDLNLD6.json"
        Alamofire.request(todoEndpoint).responseJSON { response in
            //print(response.request)  // original URL request
            //print(response.response) // HTTP URL response
            //print(response.data)     // server data
           // print(response.result)   // result of response serialization
            
         
            if let JSON = response.result.value {
                print(JSON)
                
                let data = (JSON as! String).data(using: .utf8)!
                let json2 = try? JSONSerialization.jsonObject(with: data)
                print(json2)
            }
           //var filteredList = list.map { $1.filter { ($0 as NSString).containsString("o") } }
          
        }
    }

}


