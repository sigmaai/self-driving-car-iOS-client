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

    @IBOutlet weak var sceneView: SCNView!
    
    var rosManager: RBSManager?
    var steeringPathSub: RBSSubscriber?
    var lastSteeringMessage: SteeringPathMessage!
    
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
        
        self.drawVehicleSteeringPath((TestValues.init().path_x), (TestValues.init().path_y))
        
        // set the scene to the view
        self.sceneView.scene = scene
        self.sceneView.showsStatistics = true
        
        // RBS Manager
        socketHost = "192.168.31.150:9090"
        // socketHost = "10.0.0.169:9090"
        rosManager = RBSManager.sharedManager()
        rosManager?.delegate = self
        
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
        print("connection established")
    }
    
    func manager(_ manager: RBSManager, threwError error: Error) {
        print(error.localizedDescription)
    }
    
    func manager(_ manager: RBSManager, didDisconnect error: Error?) {
        print(error?.localizedDescription ?? "connection did disconnect")
    }
    
    // MARK: Helper Methods
    
    func drawVehicleSteeringPath(_ x: [Double], _ y: [Double]){
        
        for i in stride(from: 0, to: y.count, by: 3){
            // x, y, z
            let box = SCNBox.init(width: 7, height: 2, length: 7, chamferRadius: 0.5)
            box.firstMaterial?.diffuse.contents  = UIColor(red: 0 / 255.0, green: 255.0 / 255.0, blue: 100.0 / 255.0, alpha: 1)
            
            let path = SCNNode(geometry: box)
            path.position = SCNVector3Make(Float(-y[i] * 2.5), 0, Float(-x[i] * 2.5))
            self.sceneView.scene?.rootNode.addChildNode(path)
        }
    }
    
}

