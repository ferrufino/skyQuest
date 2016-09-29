//
//  rangeridentifierViewController.swift
//  skyQuest
//
//  Created by Jessica M Cavazos Erhard on 9/29/16.
//  Copyright © 2016 itesm. All rights reserved.
//

import UIKit

class rangerIdentifierViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rangerBalloonA(_ sender: AnyObject) {
        user.id = "3"
    }
    
    @IBAction func rangerBalloonB(_ sender: AnyObject) {
        user.id = "4"
    }
}
