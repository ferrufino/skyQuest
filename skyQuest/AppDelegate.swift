//
//  AppDelegate.swift
//  skyQuest
//
//  Created by Gustavo Ferrufino De La Fuente on 9/28/16.
//  Copyright © 2016 itesm. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if user.id == "R"{ //Open in Ranger Map
            print("Ranger")
        } else if user.id == "H"{ //Open in HQ Map
            print("HQ")
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let urlString = url.absoluteString
        var param = urlString.characters.split(separator: "/").map(String.init)
        if user.id == "3"{ //If User that opened link is ranger
            if param[3] == "1" { //Balloon A
                //Change Balloon A Location
                user.changepinLocation(pinTitle: "BalloonA", lat: param[1], lon: param[2])
                
                //Open View controller
                let rootViewController = self.window!.rootViewController
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let setViewController = mainStoryboard.instantiateViewController(withIdentifier: "rangerMapViewController") as! rangerMapViewController
                rootViewController?.navigationController?.popToViewController(setViewController, animated: false)
                
            }
        } else if user.id == "0" { //If User that opened link is in HQ
            if param[3] == "1" { //Balloon A
                //Change Balloon A Location
                user.changepinLocation(pinTitle: "BalloonA", lat: param[1], lon: param[2])
            } else if param[3] == "2"{ //Balloon B
                ///Change Balloon B Location
                user.changepinLocation(pinTitle: "BalloonB", lat: param[1], lon: param[2])
            } else if param[3] == "3"{ //Ranger A
                //Change Ranger A
                user.changepinLocation(pinTitle: "RangerA", lat: param[1], lon: param[2])
            } else {  //Ranger B
                //Change Ranger B
                user.changepinLocation(pinTitle: "RangerB", lat: param[1], lon: param[2])

            }
            
            //Open HQ Map View controller
            let rootViewController = self.window!.rootViewController
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let setViewController = mainStoryboard.instantiateViewController(withIdentifier: "rangerMapViewController") as! rangerMapViewController
            rootViewController?.navigationController?.popToViewController(setViewController, animated: false)
            
        } else if user.id == "4" {
            if param[3] == "2" { //Balloon B
                ///Change Balloon B Location
                user.changepinLocation(pinTitle: "BalloonB", lat: param[1], lon: param[2])
                
                //Open View controller
                let rootViewController = self.window!.rootViewController
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let setViewController = mainStoryboard.instantiateViewController(withIdentifier: "rangerMapViewController") as! rangerMapViewController
                rootViewController?.navigationController?.popToViewController(setViewController, animated: false)
                
                
            }
        }
        
        return true
    }

}

