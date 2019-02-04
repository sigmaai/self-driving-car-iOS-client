//
//  ViewController.swift
//  Self-Driving Car User Client
//
//  Created by Yongyang Nie on 2/2/19.
//  Copyright © 2019 Yongyang Nie. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class ViewController: UIViewController, RBSManagerDelegate {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var connectButton: UIButton!
    
    var rosManager: RBSManager?
    var steeringPathSub: RBSSubscriber?
    var steeringAngleSub: RBSSubscriber?
    
    var lastPathY = [Float]()
    var lastPathX = [Float]()
    var lastSteerAngle: Float32Message!
    
    // user settings
    var socketHost: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/scene.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: +180, z: +240)
        cameraNode.rotation = SCNVector4(1, 0, 0, -Double.pi / 8)
        cameraNode.camera?.automaticallyAdjustsZRange = true
        
        scene.rootNode.addChildNode(cameraNode)
        
        // set the scene to the view
        self.sceneView.scene = scene
        self.sceneView.showsStatistics = true
        
        // RBS Manager
        // socketHost = "192.168.31.150:9090"
        socketHost = "10.0.0.169:9090"
        rosManager = RBSManager.sharedManager()
        rosManager?.delegate = self
        
        // Declare all subscribers
        steeringPathSub = rosManager?.addSubscriber(topic: "/visual/ios/steering/path", messageClass: Float32MultiArrayMessage.self, response: { (message) -> (Void) in
            self.lastPathX = Array((message as! Float32MultiArrayMessage).data[0..<101])
            self.lastPathY = Array((message as! Float32MultiArrayMessage).data[101..<202])
            DispatchQueue.main.async {
                self.drawVehicleSteeringPath(self.lastPathX, self.lastPathY)
            }
        })

        steeringAngleSub = rosManager?.addSubscriber(topic: "/vehicle/dbw/steering_cmds", messageClass: Float32Message.self, response: { (message) -> (Void) in
            self.lastSteerAngle = (message as! Float32Message)
            self.updateWithMessageAngle(self.lastSteerAngle)
        })
        
        steeringAngleSub?.messageType = "std_msgs/Float32"
        steeringPathSub?.messageType = "std_msgs/Float32MultiArray"
        
    }
    
    
    func updateWithMessageAngle(_ message: Float32Message) {
        
    }
    
    @IBAction func connectAction(_ sender: Any) {
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
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    // MARK: ROS Delegate
    
    func managerDidConnect(_ manager: RBSManager) {
        self.connectButton.backgroundColor = UIColor.red
        self.connectButton.setTitle("Disconnect", for: UIControl.State.normal)
        print("connection established")
    }
    
    func manager(_ manager: RBSManager, threwError error: Error) {
        print(error.localizedDescription)
    }
    
    func manager(_ manager: RBSManager, didDisconnect error: Error?) {
        self.connectButton.backgroundColor = UIColor.green
        self.connectButton.setTitle("Connect", for: UIControl.State.normal)
        print("connection established")
        print(error?.localizedDescription ?? "connection did disconnect")
    }
    
    // MARK: Helper Methods
    
    func drawVehicleSteeringPath(_ x: [Float], _ y: [Float]){
        
        for i in stride(from: 0, to: y.count, by: 5){
            // x, y, z
            self.sceneView.scene?.rootNode.childNode(withName: String(i), recursively: true)?.removeFromParentNode()
            
            let box = SCNBox.init(width: 7, height: 2, length: 7, chamferRadius: 0.5)
            box.firstMaterial?.diffuse.contents  = UIColor(red: 0 / 255.0, green: 255.0 / 255.0, blue: 100.0 / 255.0, alpha: 1)
        
            let path = SCNNode(geometry: box)
            path.name = String(i)
            path.position = SCNVector3Make(Float(-y[i] * 10), 0, Float(-x[i] * 5.0))
            self.sceneView.scene?.rootNode.addChildNode(path)
        }
    }
    
}

