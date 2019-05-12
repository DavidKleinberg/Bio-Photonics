//
//  AppDelegate.swift
//  Melanoma
//
//  Created by David Kleinberg on 4/29/19.
//  Copyright © 2019 David Kleinberg. All rights reserved.
//

import UIKit
import Firebase
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        
        
        let fetchRequest: NSFetchRequest<Scan> = Scan.fetchRequest()
        do {
            
            let scans = try PersistenceService.context.fetch(fetchRequest)
            global.melanomaScans = scans
            print("Retrieved CoreData")
            
            let storage = Storage.storage()
            let basePath = "appdata/"
            
            //self.tableView.reloadData()
            
            for data in global.melanomaScans {
                
                for i in 1...3 {
                    let imagePath = "\(basePath)\(data.date!)/img\(i).jpg"
                    let storageRef = storage.reference(withPath: imagePath)
                    
                    print(imagePath)
                    
                    //var size: Int64?
                    
                    // Get metadata properties
                    storageRef.getMetadata { metadata, error in
                        if let error = error {
                            // Uh-oh, an error occurred!
                            print(error)
                        } else {
                            // Metadata now contains the metadata for 'images/forest.jpg'
                            print(metadata ?? "metadata unknown")
                            //size = metadata?.size
                        }
                    }
                    
                    // Get the actual image
                    //storageRef.getData(maxSize: size!) { (imgData, imgError) in
                    storageRef.getData(maxSize: (2 * 1024 * 1024)) { (imgData, imgError) in
                        
                        if let imgError = imgError {
                            // Uh-oh, an error occurred!
                            print(imgError)
                            print("Error retrieving image")
                        } else {
                            // Metadata now contains the metadata for 'images/forest.jpg'
                            let pic = UIImage(data: imgData!)
                            global.images.append(pic!)
                            print("Retrieved image")
                        }
                    }
                }
            }
        } catch { print("Failed to retrieve CoreData") }
        
        
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
    
    
}

