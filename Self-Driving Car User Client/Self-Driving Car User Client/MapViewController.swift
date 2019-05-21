//
//  MapViewController.swift
//  Self-Driving Car User Client
//
//  Created by Yongyang Nie on 5/15/19.
//  Copyright © 2019 Yongyang Nie. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, RBSManagerDelegate, CustomTableViewCellDelegate {

    var rosManager: RBSManager?
    var destinationPublisher: RBSPublisher?
    var socketHost: String?
    var tableViewData = [Any]()
    
    let destLocation3 = CLLocationCoordinate2DMake(42.546864, -72.609187)
    let destLocation2 = CLLocationCoordinate2DMake(42.546864, -72.608882)
    let destLocation1 = CLLocationCoordinate2DMake(42.546893, -72.608540)
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableViewData = ["Destination #1", "Destination #2", "Destination #3"]
        
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
        
        // Drop a pin
        let dropPin1 = MKPointAnnotation()
        dropPin1.coordinate = destLocation3
        dropPin1.title = "Dest. #3"
        mapView.addAnnotation(dropPin1)
        
        let dropPin2 = MKPointAnnotation()
        dropPin2.coordinate = destLocation2
        dropPin2.title = "Dest. #2"
        mapView.addAnnotation(dropPin2)
        
        let dropPin3 = MKPointAnnotation()
        dropPin3.coordinate = destLocation1
        dropPin3.title = "Dest. #1"
        mapView.addAnnotation(dropPin3)
        
        // ROS websocket
        socketHost = UserDefaults.standard.object(forKey: "connectionIP") as? String       // "192.168.42.109:9090"
        rosManager = RBSManager.sharedManager()
        rosManager?.delegate = self
        
        destinationPublisher = rosManager?.addPublisher(topic: "/dest_select", messageType: "std_msgs/Int32", messageClass: Int32Message.self)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        connectWebSocket()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        connectWebSocket()
//        rosManager = nil
//        socketHost = nil
    }
    
    func connectWebSocket() {
        
        socketHost = UserDefaults.standard.object(forKey: "connectionIP") as? String

        if socketHost != nil {
            // the manager will produce a delegate error if the socket host is invalid
            rosManager?.connect(address: socketHost!)
        } else {
            print("Missing socket host value --> use host button")
        }
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
    
    // MARK: - UITableView
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCellID", for: indexPath) as! CustomTableViewCell
        cell.delegate = self
        
        cell.label?.text = "Destination #\(indexPath.row + 1)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        if (indexPath.row == 0){
            let viewRegion = MKCoordinateRegion(center: destLocation1, latitudinalMeters: 150, longitudinalMeters: 150)
            mapView.setRegion(viewRegion, animated: false)
        }else if (indexPath.row == 1){
            let viewRegion = MKCoordinateRegion(center: destLocation2, latitudinalMeters: 150, longitudinalMeters: 150)
            mapView.setRegion(viewRegion, animated: false)
        }else if (indexPath.row == 2){
            let viewRegion = MKCoordinateRegion(center: destLocation3, latitudinalMeters: 150, longitudinalMeters: 150)
            mapView.setRegion(viewRegion, animated: false)
        }
    }
    
    // MARK: - TableViewCell delegate
    
    func cellButtonClicked(cell: CustomTableViewCell) {
        
        let index = tableView.indexPath(for: cell)
        print(index!.row)
        
        let message = Int32Message()
        message.data = Int32(index!.row)

        self.destinationPublisher?.publish(message)
        
        let alert = UIAlertController(title: "Destination Sent to Vehicle", message: "Please navigation to the driving screen and click \"Go\"", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler:{ (UIAlertAction)in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
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
