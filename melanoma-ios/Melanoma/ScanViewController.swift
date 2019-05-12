//
//  CameraViewController.swift
//  Melanoma
//
//  Created by David Kleinberg on 4/28/19.
//  Copyright © 2019 David Kleinberg. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, AVCapturePhotoCaptureDelegate {
    
    // Global class variables
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?
    var pictureFrameView: UIView?
    var imageCaptures: [UIImage?] = []
    
    var scanTimer: Timer?
    var numCaptures = 0
    
    lazy var storage = Storage.storage()
    //var bleController: BluetoothSerial?
    //var bleController = BluetoothSerial()
    //var bleDelegate: 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.prepareCamera()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopCaptureSession()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func stopCaptureSession() {
        self.captureSession!.stopRunning()
        if let inputs = captureSession!.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.captureSession!.removeInput(input)
            }
        }
    }
    
    func prepareCamera() {
        // Get an instance of the AVCaptureDevice class to initialize
        // a device object and provide the video as the media type parameter
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            fatalError("No video device found")
        }
        
        do { //beginCameraSession(captureDevice: captureDevice)
            
            // Get an instance of the AVCaptureDeviceInput class using the previous deivce object
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object
            self.captureSession = AVCaptureSession()
            
            // Set the input devcie on the capture session
            self.captureSession?.addInput(input)
            
            // Get an instance of ACCapturePhotoOutput class
            self.capturePhotoOutput = AVCapturePhotoOutput()
            self.capturePhotoOutput?.isHighResolutionCaptureEnabled = true
            
            // Set the output on the capture session
            self.captureSession?.addOutput(capturePhotoOutput!)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the input device
            let captureMetadataOutput = AVCaptureMetadataOutput()
            self.captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self as AVCaptureMetadataOutputObjectsDelegate, queue: DispatchQueue.main)
            //captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            //Initialise the video preview layer and add it as a sublayer to the viewPreview view's layer
            self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.videoPreviewLayer?.frame = view.layer.bounds
            //self.view.layer.addSublayer(videoPreviewLayer!)
            self.view.layer.insertSublayer(self.videoPreviewLayer!, at: 0)
            
            //start video capture
            captureSession?.startRunning()
            
            //Initialize picture Frame
            pictureFrameView = UIView()

            if let pictureFrameView = pictureFrameView {
                pictureFrameView.layer.borderColor = UIColor.green.cgColor
                pictureFrameView.layer.borderWidth = 2
                self.view.addSubview(pictureFrameView)
                //self.view.bringSubviewToFront(pictureFrameView)
            }
            
        } catch {
            //If any error occurs, simply print it out
            print(error)
            return
        }
        
    }
    
    //func beginCameraSession(captureDevice: AVCaptureDevice) {}

//    override func viewDidLayoutSubviews() {
//        self.videoPreviewLayer?.frame = view.bounds
//        if let previewLayer = self.videoPreviewLayer ,(previewLayer.connection?.isVideoOrientationSupported)! {
//            previewLayer.connection?.videoOrientation = UIApplication.shared.statusBarOrientation.videoOrientation ?? .portrait
//        }
//    }
    
    
    @IBAction func startScanPressed(_ sender: UIButton) {
        
        guard checkBLEstatus() else {
            return
        }
        
        //Start the timer
        if self.scanTimer == nil {
            
            // Make sure capturePhotoOutput is valid
            guard let capturePhotoOutput = self.capturePhotoOutput else { return }
            
            // Get an instance of AVCapturePhotoSettings class
            let photoSettings = AVCapturePhotoSettings()
            
            // Set photo settings for our need
            photoSettings.isAutoStillImageStabilizationEnabled = true
            photoSettings.isHighResolutionPhotoEnabled = true
            photoSettings.flashMode = .on
            
            // Call capturePhoto method by passing our photo settings and a delegate implementing AVCapturePhotoCaptureDelegate
            print("Image Capture #1")
            self.numCaptures += 1
            capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self as AVCapturePhotoCaptureDelegate)
        }
    }
    
    
    func checkBLEstatus() -> Bool {
        if global.bleConnected {
            return true
        } else {
            
            let alert = UIAlertController(title: "BLE Module Not Connected", message: "Please check device power and try again", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
            
            return false
        }
    }
    
    //this is basically repeated code. but it's okay
    @objc func fireTimer() {
        self.numCaptures += 1
        print("Image Capture #\(self.numCaptures)")
        
        //let bleController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Bluetooth") as! BluetoothSerial
        
        global.bleController!.setLighting(color: self.numCaptures)
        
        //NotificationCenter.post(name: Notification.Name("setLightingNotification"), object: nil)
        
        // Make sure capturePhotoOutput is valid
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }
        
        // Get an instance of AVCapturePhotoSettings class
        let photoSettings = AVCapturePhotoSettings()
        
        // Set photo settings for our need
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .off
        
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self as AVCapturePhotoCaptureDelegate)
    }
    
    func firebaseUpload() {
        
        let timestamp = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .medium, timeStyle: .short)
        
        let firebaseScan = Scan(context: PersistenceService.context)
        firebaseScan.date = timestamp
        PersistenceService.saveContext()
        global.melanomaScans.append(firebaseScan)
        
        for (idx,img) in self.imageCaptures.enumerated() {
            
            guard let imageData = img!.jpegData(compressionQuality: 0.8) else { return }
            
            let imagePath = "appdata/\(timestamp)/img\(idx).jpg"
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            let storageRef = self.storage.reference(withPath: imagePath)
            storageRef.putData(imageData, metadata: metadata) { (metadata, error) in
                if let error = error {
                    print("Error uploading: \(error)")
                    //self.urlTextView.text = "Upload Failed"
                    print("Upload Failed")
                    return
                }
                self.uploadSuccess(storageRef, storagePath: imagePath)
            }
        }
    }
    
    func uploadSuccess(_ storageRef: StorageReference, storagePath: String) {
        print("Upload Succeeded!")
        storageRef.downloadURL { (url, error) in
            if let error = error {
                print("Error getting download URL: \(error)")
                //self.urlTextView.text = "Can't get download URL"
                print("Can't get download URL")
                return
            }
            //self.urlTextView.text = url?.absoluteString ?? ""
            print(url?.absoluteString ?? "")
            UserDefaults.standard.set(storagePath, forKey: "storagePath")
            UserDefaults.standard.synchronize()
            //self.downloadPicButton.isEnabled = true
        }
    }
    
    func scanningComplete() {
        
        //turn off the last LED
        global.bleController?.setLighting(color: -1)
        self.stopCaptureSession()
        
        let alert = UIAlertController(title: "Scanning Complete!", message: "Would you like to begin processing?", preferredStyle: .alert)
        //"Processing will begin shortly"
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (handler) in
            self.firebaseUpload()
            self.imageCaptures = []
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(alert, animated: true)
        
        //Segue into the history screen:
//        let historyScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "History") as! HistoryViewController
//        //historyScreen.takenPhoto = image
//
//        DispatchQueue.main.async {
//            self.present(historyScreen, animated: true, completion: {
//                self.stopCaptureSession()
//            })
//        }
    }

    //EXTEND the AVCapturePhotoCaptureDelegate
    func photoOutput(_ captureOutput: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                     previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                     resolvedSettings: AVCaptureResolvedPhotoSettings,
                     bracketSettings: AVCaptureBracketedStillImageSettings?,
                     error: Error?) {
        
        // Make sure we get some photo sample buffer
        guard error == nil,
            let photoSampleBuffer = photoSampleBuffer else {
                print("Error capturing photo: \(String(describing: error))")
                return
        }
        
        // Convert photo same buffer to a jpeg image data by using AVCapturePhotoOutput
        guard let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {
            return
        }
        
        // Initialise an UIImage with our image data
        let capturedImage = UIImage.init(data: imageData , scale: 1.0)
        if let image = capturedImage {
            
            // Save our captured image to the array
            print("CAPTURED!")
            self.imageCaptures.append(image)
            
            if self.scanTimer == nil {
                self.scanTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
                //timer1.tolerance = 0.2
                self.scanTimer!.fire()
            } else if numCaptures == 4 {
                self.scanTimer!.invalidate()
                self.scanTimer = nil
                self.numCaptures = 0
                
                self.scanningComplete()
            }
        }
    }
}
