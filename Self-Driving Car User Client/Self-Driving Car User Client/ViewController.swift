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

    // UI Elements
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    var inputTextField: UITextField!
    
    // ROS
    var rosManager: RBSManager?
    var steeringPathSub: RBSSubscriber?
    var steeringAngleSub: RBSSubscriber?
    var initPublisher: RBSPublisher?
    
    var lastPathY = [Float]()
    var lastPathX = [Float]()
    var lastSteerAngle: Float32Message!
    var vehicleInit = false;
    
    // user settings
    var socketHost: String?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.connectButton.backgroundColor = UIColor.init(red: 96.0 / 255.0, green: 177.0 / 255.0, blue: 87.0 / 255.0, alpha: 1.0)
        
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
        
        // RBS Manager "192.168.42.109:9090"
        socketHost = UserDefaults.standard.object(forKey: "connectionIP") as? String
        rosManager = RBSManager.sharedManager()
        rosManager?.delegate = self
        
        initPublisher = rosManager?.addPublisher(topic: "/vehicle/dbw/go", messageType: "std_msgs/Bool", messageClass: BoolMessage.self)
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        updateViewBasedOnConnection()
    }
    
    func updateWithMessageAngle(_ message: Float32Message) {
        
    }
    
    // MARK: IBAction
    
    @IBAction func emergency(_ sender: Any) {
        
    }
    
    @IBAction func goAction(_ sender: Any) {
        
        let message = BoolMessage()
        message.data = !self.vehicleInit
        self.vehicleInit = !self.vehicleInit
        if self.vehicleInit {
            self.goButton.setImage(UIImage(named: "stop_sign"), for: UIControl.State.normal)
        }else{
            self.goButton.setImage(UIImage(named: "go_sign"), for: UIControl.State.normal)
        }
        self.initPublisher?.publish(message)
    }
    
    @IBAction func connectAction(_ sender: Any) {
        
        socketHost = UserDefaults.standard.object(forKey: "connectionIP") as? String

        if rosManager?.connected == true {
            rosManager?.disconnect()
        } else {
            if socketHost != nil {
                // the manager will produce a delegate error if the socket host is invalid
                rosManager?.connect(address: socketHost!)
            } else {
                print("Missing socket host value --> use host button")
            }
        }
        
        updateViewBasedOnConnection()
    }
    
    @IBAction func setPreference(_ sender: Any) {
        
        let alert = UIAlertController(title: "Set IP Address", message: "Please set the IP address of the connection", preferredStyle: UIAlertController.Style.alert)
        
        alert.addTextField(configurationHandler: configurationTextField)

        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler:{ (UIAlertAction)in
            print("Set new IP address: " + self.inputTextField.text!)
            UserDefaults.standard.set(self.inputTextField.text!, forKey: "connectionIP")
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func configurationTextField(textField: UITextField!){
        
        print("configurat hire the TextField")
        
        if textField != nil {
            self.inputTextField = textField!        //Save reference to the UITextField
            self.inputTextField.text = UserDefaults.standard.object(forKey: "connectionIP") as? String
        }
    }
    
    func updateViewBasedOnConnection() {
        
        if rosManager?.connected == true {
            self.statusLabel.text = "Status: Connected"
            self.connectButton.backgroundColor = UIColor.red
            self.connectButton.setTitle("Disconnect", for: UIControl.State.normal)
            print("[STATUS]: connected")
        }else{
            self.statusLabel.text = "Status: Disconnected"
            self.connectButton.backgroundColor = UIColor.init(red: 96.0 / 255.0, green: 179.0 / 255.0, blue: 87.0 / 255.0, alpha: 1.0)
            self.connectButton.setTitle("Connect", for: UIControl.State.normal)
            print("[STATUS]: disconnected")
        }
    }
    
    // MARK: ROS Delegate
    
    func managerDidConnect(_ manager: RBSManager) {
        self.statusLabel.text = "Status: Connected"
        self.connectButton.backgroundColor = UIColor.red
        self.connectButton.setTitle("Disconnect", for: UIControl.State.normal)
        print("[STATUS]: connected")
    }
    
    func manager(_ manager: RBSManager, threwError error: Error) {
        print(error.localizedDescription)
    }
    
    func manager(_ manager: RBSManager, didDisconnect error: Error?) {
        self.statusLabel.text = "Status: Disconnected"
        self.connectButton.backgroundColor = UIColor.init(red: 96.0 / 255.0, green: 179.0 / 255.0, blue: 87.0 / 255.0, alpha: 1.0)
        self.connectButton.setTitle("Connect", for: UIControl.State.normal)
        print("[STATUS]: disconnected")
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
    
}

