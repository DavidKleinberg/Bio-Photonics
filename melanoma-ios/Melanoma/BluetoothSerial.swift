//
//  BluetoothSerial.swift
//  Melanoma
//
//  Created by David Kleinberg on 4/29/19.
//  Copyright © 2019 David Kleinberg. All rights reserved.
//

import UIKit
import Foundation
import CoreBluetooth

//protocol BLEDelegate {
//    func setLighting(color: Int)
//}

class BluetoothSerial: UIViewController { //BLEDelegate { //NSObject,
    
    // MARK: Variables
    
    /// The delegate object the BluetoothDelegate methods will be called upon
    //var delegate: BluetoothSerialDelegate!
    
    /// The CBCentralManager this bluetooth serial handler uses for... well, everything really
    var centralManager: CBCentralManager!
    
    /// The peripheral we're trying to connect to (nil if none)
    var pendingPeripheral: CBPeripheral?
    
    /// The connected peripheral (nil if none is connected)
    var connectedPeripheral: CBPeripheral?
    
    /// The characteristic 0xFFE1 we need to write to, of the connectedPeripheral
    weak var writeCharacteristic: CBCharacteristic?
    
    /// UUID of the service to look for.
    var serviceUUID = CBUUID(string: "FFE0")
    
    /// UUID of the characteristic to look for.
    var characteristicUUID = CBUUID(string: "FFE1")
    
    /// Legit HM10 modules 'Write without Response'.
    private var writeType: CBCharacteristicWriteType = .withoutResponse
    
    /// Whether this serial is ready to send and receive data
    var isReady: Bool {
        get {
            return centralManager.state == .poweredOn &&
                connectedPeripheral != nil &&
                writeCharacteristic != nil
        }
    }
    
    /// Whether this serial is looking for advertising peripherals
    var isScanning: Bool {
        return centralManager.isScanning
    }
    
    /// Whether the state of the centralManager is .poweredOn
    var isPoweredOn: Bool {
        return centralManager.state == .poweredOn
    }
    
    
    // ------------------------------------------------------------ //
    
    
    //@IBOutlet weak var bleConsole: UITextView!
    @IBOutlet weak var CBManagerStatus: UILabel!
    @IBOutlet weak var CBScanningStatus: UILabel!
    
    @IBOutlet weak var CBPeripheralStatus: UILabel!
    @IBOutlet weak var CBConnectedStatus: UILabel!

    @IBOutlet weak var DisconnectButton: UIButton!
    
    @IBAction func DisconnectButtonPressed(_ sender: UIButton) {
        
        if self.connectedPeripheral != nil {
            self.centralManager.cancelPeripheralConnection(self.connectedPeripheral!)
            self.CBPeripheralStatus.text = "Device not connected"
            global.bleConnected = false
        }
    }
    // ------------------------------------------------------------ //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize the CoreBluetooth manager
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        
        global.bleController = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(setLighting),name:NSNotification.Name(rawValue: "setLightingNotification"), object: nil)
        
        // we might want to migrate this to the MAIN view controller
        // or the veiwDidLoad
        //self.startScan()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //self.stopScan()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: functions
    
    /// Start scanning for peripherals
    func startScan() {
        guard self.centralManager.state == .poweredOn else { return }
        
        print("starting BLE scan...")
        self.CBScanningStatus.text = "scanning..."
        
        // start scanning for peripherals with correct service UUID
        self.centralManager.scanForPeripherals(withServices: [self.serviceUUID], options: nil)
        
        // retrieve peripherals that are already connected
        let peripherals = self.centralManager.retrieveConnectedPeripherals(withServices: [self.serviceUUID])
        for peripheral in peripherals {
            //self.serialDidDiscoverPeripheral(peripheral, RSSI: nil)
            print("Connected Peripheral: \(peripheral)")
            self.CBPeripheralStatus.text = "Connected Peripheral: \(peripheral)"
        }
    }
    
    /// Stop scanning for peripherals
    func stopScan() {
        self.centralManager.stopScan()
    }
    
//    /// Try to connect to the given peripheral
//    func connectToPeripheral(_ peripheral: CBPeripheral) {
//        pendingPeripheral = peripheral
//        self.centralManager.connect(peripheral, options: nil)
//    }
    
    /// Disconnect from the connected peripheral or stop connecting to it
    func disconnect() {
        if let p = connectedPeripheral {
            centralManager.cancelPeripheralConnection(p)
        } else if let p = pendingPeripheral {
            centralManager.cancelPeripheralConnection(p) //TODO: Test whether its neccesary to set p to nil
        }
    }
    
    /// The didReadRSSI delegate function will be called after calling this function
    func readRSSI() {
        guard isReady else { return }
        connectedPeripheral!.readRSSI()
    }
    
    /// Send a string to the device
    func sendMessageToDevice(_ message: String) {
        guard isReady else { return }
        
        if let data = message.data(using: String.Encoding.utf8) {
            connectedPeripheral!.writeValue(data, for: writeCharacteristic!, type: writeType)
        }
    }
    
    /// Send an array of bytes to the device
    func sendBytesToDevice(_ bytes: [UInt8]) {
        guard isReady else { return }
        
        //we are calling this from the ScanViewController!!!
        //bleConsole.insertText("sending [\(bytes)] to device")
        let data = Data(bytes: UnsafePointer<UInt8>(bytes), count: bytes.count)
        connectedPeripheral!.writeValue(data, for: writeCharacteristic!, type: writeType)
    }
    
    /// Send data to the device
    func sendDataToDevice(_ data: Data) {
        guard isReady else { return }
        
        connectedPeripheral!.writeValue(data, for: writeCharacteristic!, type: writeType)
    }
    
    // ------------------------------------------------------------ //
    
    // ------------------------------------------------------------ //
    
    //@objc func setLighting(color: Int) -> Void {
    func setLighting(color: Int) -> Void {
        switch color {
        case 2:
            print("lighting with _____nm")
            //we are calling this from the ScanViewController!!!
            //self.bleConsole.insertText("lighting with _____nm")
            //self.sendBytesToDevice([2])
            self.sendMessageToDevice("1")
            
        case 3:
            print("lighting with _____nm")
            //self.bleConsole.insertText("lighting with _____nm")
            //self.sendBytesToDevice([3])
            self.sendMessageToDevice("2")
            
        case 4:
            print("lighting with _____nm")
            //self.bleConsole.insertText("lighting with _____nm")
            //self.sendBytesToDevice([4])
            self.sendMessageToDevice("3")
            
        default:
            print("UNKNOWN")
            
            // sending garbage will turn it off
            self.sendMessageToDevice("X")
        }
    }
}
    
    
// MARK: CBCentralManagerDelegate functions
extension BluetoothSerial: CBCentralManagerDelegate {
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // just send it to the delegate
        //delegate.serialDidDiscoverPeripheral(peripheral, RSSI: RSSI)
        
        // save the bluetooth module that was found
        self.pendingPeripheral = peripheral
        
//        // request permission
//        if requestConnection() {
//
//            // initiate connection
//            self.centralManager.connect(self.pendingPeripheral!, options: nil)
//        }
        
        let alert = UIAlertController(title: "Connect to device?", message: "\(self.pendingPeripheral?.name! ?? "unknown" )", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (handler) in
            self.centralManager.connect(self.pendingPeripheral!, options: nil)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil ))
        
        self.present(alert, animated: true)
    }
    
    func requestConnection() -> Bool {
        
        var shouldConnect: Bool?
        
        let alert = UIAlertController(title: "Connect to device?", message: "\(self.pendingPeripheral?.name! ?? "unknown" )", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (handler) in
            shouldConnect = true
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (handler) in
            shouldConnect = false
        }))
        self.present(alert, animated: true)
        
        return shouldConnect!
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to: \(peripheral)")
        self.CBConnectedStatus.text = "Connected to: \(peripheral)"
        self.pendingPeripheral = nil
        self.connectedPeripheral = peripheral
        global.bleConnected = true
        
        // Okay, the peripheral is connected but we're not ready yet!
        // First get the 0xFFE0 service
        // Then get the 0xFFE1 characteristic of this service
        // Subscribe to it & create a weak reference to it (for writing later on),
        // and find out the writeType by looking at characteristic.properties.
        // Only then we're ready for communication
        
        self.connectedPeripheral?.delegate = self
        self.connectedPeripheral!.discoverServices([serviceUUID])
    }
    
//    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
//        connectedPeripheral = nil
//        pendingPeripheral = nil
//
//        // send it to the delegate
//        delegate.serialDidDisconnect(peripheral, error: error as NSError?)
//    }
//
//    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
//        pendingPeripheral = nil
//
//        // just send it to the delegate
//        delegate.serialDidFailToConnect(peripheral, error: error as NSError?)
//    }
//
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
            self.CBManagerStatus.text = "central.state is .unknown"
            
        case .resetting:
            print("central.state is .resetting")
            self.CBManagerStatus.text = "central.state is .resetting"
            
        case .poweredOff:
            print("central.state is .poweredOff")
            self.CBManagerStatus.text = "central.state is .poweredOff"
            
        case .poweredOn:
            print("central.state is .poweredOn")
            //centralManager.scanForPeripherals(withServices: nil)
            self.CBManagerStatus.text = "central.state is .poweredOn"
            self.startScan()
            
        case .unauthorized:
            print("central.state is .unauthorized")
            self.CBManagerStatus.text = "central.state is .unauthorized"
            
        case .unsupported:
            print("central.state is .unsupported")
            self.CBManagerStatus.text = "central.state is .unsupported"
            
        @unknown default:
            print("UNKNOWN")
        }
    }
}

// MARK: CBPeripheralDelegate functions
extension BluetoothSerial: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // discover the 0xFFE1 characteristic for all services (though there should only be one)
        for service in peripheral.services! {
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // check whether the characteristic we're looking for (0xFFE1) is present - just to be sure
        for characteristic in service.characteristics! {
            if characteristic.uuid == characteristicUUID {
                // subscribe to this value (so we'll get notified when there is serial data for us..)
                peripheral.setNotifyValue(true, for: characteristic)
                
                // keep a reference to this characteristic so we can write to it
                self.writeCharacteristic = characteristic
                
                // find out writeType
                self.writeType = characteristic.properties.contains(.write) ? .withResponse : .withoutResponse
            }
        }
    }
    
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        // notify the delegate in different ways
//        // if you don't use one of these, just comment it (for optimum efficiency :])
//        let data = characteristic.value
//        guard data != nil else { return }
//
//        // first the data
//        delegate.serialDidReceiveData(data!)
//
//        // then the string
//        if let str = String(data: data!, encoding: String.Encoding.utf8) {
//            delegate.serialDidReceiveString(str)
//        } else {
//            //print("Received an invalid string!") uncomment for debugging
//        }
//
//        // now the bytes array
//        var bytes = [UInt8](repeating: 0, count: data!.count / MemoryLayout<UInt8>.size)
//        (data! as NSData).getBytes(&bytes, length: data!.count)
//        delegate.serialDidReceiveBytes(bytes)
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
//        delegate.serialDidReadRSSI(RSSI)
//    }
}
