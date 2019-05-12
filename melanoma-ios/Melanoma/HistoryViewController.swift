//
//  PhotoViewController.swift
//  Melanoma
//
//  Created by David Kleinberg on 4/4/19.
//  Copyright © 2019 David Kleinberg. All rights reserved.
//

import UIKit
import Firebase
import CoreData
import AVFoundation

class HistoryViewController: UIViewController, UITableViewDataSource { //, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // this will hold the history of scans
    @IBOutlet weak var tableView: UITableView!
    
    lazy var storage = Storage.storage()
    
    //var images = [UIImage]()

    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func goBack(_ sender: AnyObject) {
        //self.takenPhoto = nil
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        
        //storageRef.getData(maxSize: <#T##Int64#>, completion: <#T##(Data?, Error?) -> Void#>)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
        return input.rawValue
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("HELLO1")
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("HELLO2")
        return global.melanomaScans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Loading tableView...")
        print("We have \(global.images.count) images")
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = global.melanomaScans[indexPath.row].date
        
        // obviously we need to fix this
        if global.images.count > indexPath.row {
            cell.imageView!.image = global.images[indexPath.row]
            print("setting tableview image")
        }
        return cell
    }
    
    
}
