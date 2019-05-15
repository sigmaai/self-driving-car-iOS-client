//
//  MapViewController.swift
//  Self-Driving Car User Client
//
//  Created by Yongyang Nie on 5/15/19.
//  Copyright © 2019 Yongyang Nie. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, RBSManagerDelegate{
    
    var rosManager: RBSManager?
    var destinationPublisher: RBSPublisher?
    var socketHost: String?
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MapKit
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Check for Location Services
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        
        //Zoom to user location
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 200, longitudinalMeters: 200)
            mapView.setRegion(viewRegion, animated: false)
        }
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
        
        // ROS websocket
        // RBS Manager "192.168.42.109:9090"
        socketHost = UserDefaults.standard.object(forKey: "connectionIP") as? String
        rosManager = RBSManager.sharedManager()
        rosManager?.delegate = self
        
        destinationPublisher = rosManager?.addPublisher(topic: "/destination", messageType: "std_msgs/Int32", messageClass: BoolMessage.self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    // MARK: ROS Delegate
    
    func managerDidConnect(_ manager: RBSManager) {
        print("[STATUS]: connected")
    }
    
    func manager(_ manager: RBSManager, threwError error: Error) {
        print(error.localizedDescription)
    }
    
    func manager(_ manager: RBSManager, didDisconnect error: Error?) {
        print("[STATUS]: disconnected")
        print(error?.localizedDescription ?? "connection did disconnect")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
