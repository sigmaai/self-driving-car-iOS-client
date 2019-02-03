//
//  ViewController.swift
//  Self-Driving-Car Developer Client
//
//  Created by Yongyang Nie on 2/2/19.
//  Copyright © 2019 Yongyang Nie. All rights reserved.
//

import UIKit

class ViewController: UIViewController, RBSManagerDelegate{
    
    @IBOutlet weak var rgbImgView: UIImageView!
    @IBOutlet weak var rgbImgView2: UIImageView!
    @IBOutlet weak var rgbImgView3: UIImageView!
    
    var rosManager: RBSManager?
    var mainImageSub1: RBSSubscriber?
    var mainImageSub2: RBSSubscriber?
    var mainImageSub3: RBSSubscriber?
    var lastImgMessage: ImageMessage!
    
    // user settings
    var socketHost: String?
    
    override func viewDidLoad() {
        
        socketHost = "192.168.31.150:9090"
        // socketHost = "10.0.0.169:9090"
        
        // initialize ROS manager
        rosManager = RBSManager.sharedManager()
        rosManager?.delegate = self
        
        // subscribe to main image output /vehicle/sensor/camera/front/image_color
        mainImageSub1 = rosManager?.addSubscriber(topic: "cv_camera_node/image_sim_vis1", messageClass: ImageMessage.self, response: { (message) -> (Void) in
            // store the message for other operations
            self.lastImgMessage = (message as! ImageMessage)

            // update the view with message data
            self.updateWithMessage1(self.lastImgMessage)
        })
        mainImageSub1?.messageType = "sensor_msgs/Image"
        
        
        mainImageSub2 = rosManager?.addSubscriber(topic: "cv_camera_node/image_sim_vis2", messageClass: ImageMessage.self, response: { (message) -> (Void) in
            // store the message for other operations
            self.lastImgMessage = (message as! ImageMessage)
            
            // update the view with message data
            self.updateWithMessage2(self.lastImgMessage)
        })
        mainImageSub2?.messageType = "sensor_msgs/Image"
        
        mainImageSub3 = rosManager?.addSubscriber(topic: "cv_camera_node/image_sim_vis3", messageClass: ImageMessage.self, response: { (message) -> (Void) in
            // store the message for other operations
            self.lastImgMessage = (message as! ImageMessage)
            
            // update the view with message data
            self.updateWithMessage3(self.lastImgMessage)
        })
        mainImageSub3?.messageType = "sensor_msgs/Image"
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func updateWithMessage1(_ message: ImageMessage) {
//        let imageData = self.image(fromPixelValues: message.data, width: message.width, height: message.height)
        let imageData = self.image(fromPixelValues: message.data, width: 160, height: 120)

        DispatchQueue.main.async {
            self.rgbImgView.image = UIImage.init(cgImage: imageData!)
        }
    }
    
    func updateWithMessage2(_ message: ImageMessage) {
        //        let imageData = self.image(fromPixelValues: message.data, width: message.width, height: message.height)
        let imageData = self.image(fromPixelValues: message.data, width: 160, height: 120)
        
        DispatchQueue.main.async {
            self.rgbImgView2.image = UIImage.init(cgImage: imageData!)
        }
    }
    
    func updateWithMessage3(_ message: ImageMessage) {
        //        let imageData = self.image(fromPixelValues: message.data, width: message.width, height: message.height)
        let imageData = self.image(fromPixelValues: message.data, width: 160, height: 120)
        
        DispatchQueue.main.async {
            self.rgbImgView3.image = UIImage.init(cgImage: imageData!)
        }
    }
    
    // MARK: ROS Delegates
    
    func managerDidConnect(_ manager: RBSManager) {
        print("connection established")
    }
    
    func manager(_ manager: RBSManager, threwError error: Error) {
        print(error.localizedDescription)
    }
    
    func manager(_ manager: RBSManager, didDisconnect error: Error?) {
        print(error?.localizedDescription ?? "connection did disconnect")
    }
    
    // MARK: IBActions
    
    @IBAction func onConnectButton() {
        if rosManager?.connected == true {
            rosManager?.disconnect()
        } else {
            if socketHost != nil {
                // the manager will produce a delegate error if the socket host is invalid
                rosManager?.connect(address: socketHost!)
            } else {
                // print log error
                print("Missing socket host value --> use host button")
            }
        }
    }
    
    func image(fromPixelValues pixelValues: [UInt8]?, width: Int, height: Int) -> CGImage?
    {
        var imageRef: CGImage?
        if var pixelValues = pixelValues {
            let bitsPerComponent = 8
            let bytesPerPixel = 3
            let bitsPerPixel = bytesPerPixel * bitsPerComponent
            let bytesPerRow = bytesPerPixel * width
            let totalBytes = height * bytesPerRow
            
            imageRef = withUnsafePointer(to: &pixelValues, {
                ptr -> CGImage? in
                var imageRef: CGImage?
                let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
                let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue).union(CGBitmapInfo())
                let data = UnsafeRawPointer(ptr.pointee).assumingMemoryBound(to: UInt8.self)
                let releaseData: CGDataProviderReleaseDataCallback = {
                    (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in
                }
                
                if let providerRef = CGDataProvider(dataInfo: nil, data: data, size: totalBytes, releaseData: releaseData) {
                    imageRef = CGImage(width: width,
                                       height: height,
                                       bitsPerComponent: bitsPerComponent,
                                       bitsPerPixel: bitsPerPixel,
                                       bytesPerRow: bytesPerRow,
                                       space: colorSpaceRef,
                                       bitmapInfo: bitmapInfo,
                                       provider: providerRef,
                                       decode: nil,
                                       shouldInterpolate: false,
                                       intent: CGColorRenderingIntent.defaultIntent)
                }
                
                return imageRef
            })
        }
        
        return imageRef
    }

}

