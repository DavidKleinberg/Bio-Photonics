//
//  ViewController.swift
//  Melanoma
//
//  Created by David Kleinberg on 4/29/19.
//  Copyright © 2019 David Kleinberg. All rights reserved.
//

import UIKit
import Firebase

var global = Global()

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Using Cloud Storage for Firebase requires the user be authenticated. Here we are using
        // anonymous authentication.
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously(completion: { (authResult, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

