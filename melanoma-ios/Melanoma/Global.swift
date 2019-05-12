//
//  Global.swift
//  Melanoma
//
//  Created by David Kleinberg on 4/29/19.
//  Copyright © 2019 David Kleinberg. All rights reserved.
//

import UIKit
import Foundation

class Global {
    static let sharedInstance = Global()
    var bleController: BluetoothSerial?
    var melanomaScans = [Scan]()
    var images = [UIImage]()
    var bleConnected = false
}
