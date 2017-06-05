//
//  ViewController.swift
//  viewController_MapKitView
//
//  Created by Luthfi Fathur Rahman on 5/26/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @available(iOS 2.0, *)
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @IBOutlet weak var btn_mapType: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    
    let mapType_Picker = UIPickerView()
    let mapType_data = ["Standard", "Satellite", "Hybrid"]
    let toolBar = UIToolbar()
    var lokasiAwal: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        checkLocationAuthorizationStatus()
        mapView.showsPointsOfInterest = true
        mapView.showsBuildings = true
        mapView.showsTraffic = true
        
        btn_mapType.backgroundColor = UIColor.white
        btn_mapType.setTitle(mapType_data[mapView.mapType.hashValue], for: .normal)
        
        mapView.delegate = self
        
        mapType_Picker.frame = CGRect(x: 0, y: view.frame.size.height-200, width: self.view.frame.width, height: 220.0)
        mapType_Picker.backgroundColor = UIColor.gray
        mapType_Picker.delegate = self
        mapType_Picker.dataSource = self
        
        toolBar.frame = CGRect(x: 0, y: mapType_Picker.frame.size.height+210, width: self.view.frame.width, height: 30.0)
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.cancelPicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.isHidden = true
        mapType_Picker.isHidden = true
        view.addSubview(mapType_Picker)
        view.addSubview(toolBar)
        
        let tapAnywhere: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(ViewController.handleTap))
        mapView.addGestureRecognizer(tapAnywhere)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKPointAnnotation {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            
            pinAnnotationView.pinTintColor = .purple
            pinAnnotationView.isDraggable = true
            pinAnnotationView.canShowCallout = true
            pinAnnotationView.animatesDrop = true
            
            return pinAnnotationView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        
        let anotasi = view.annotation as! MKPointAnnotation
        anotasi.title = "\((view.annotation?.coordinate.latitude)!), \((view.annotation?.coordinate.longitude)!)"
    }
    
    func centerOnlocation(_ location: CLLocation, _ regionRadius: Double){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    
    }
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            mapView.showsUserLocation = true
            lokasiAwal = CLLocation(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!)
            centerOnlocation(lokasiAwal!, 1000) //radius dalam satuan meter
        } else if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted {
            lokasiAwal = CLLocation(latitude: 37.33182, longitude: -122.03118) //dummy location: Apple Campus, Cupertino
            centerOnlocation(lokasiAwal!, 1000)
        }
    }

    @IBAction func btn_mapType(_ sender: UIButton) {
        mapType_Picker.isHidden = false
        toolBar.isHidden = false
        mapType_Picker.selectRow(mapType_Picker.selectedRow(inComponent: 0), inComponent: 0, animated: true)
        view.bringSubview(toFront: mapType_Picker)
    }
    
    //UIPickerViewDelegate & UIPickerViewDataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return mapType_data.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return mapType_data[row]
    }
    
    func donePicker()
    {
        let row = mapType_Picker.selectedRow(inComponent: 0)
        mapView.mapType = MKMapType(rawValue: UInt(row))!
        btn_mapType.setTitle(mapType_data[row], for: .normal)
        self.view.endEditing(true)
        mapType_Picker.isHidden = true
        toolBar.isHidden = true
    }
    
    func cancelPicker(){
        self.view.endEditing(true)
        mapType_Picker.isHidden = true
        toolBar.isHidden = true
    }
    
    func handleTap(gestureReconizer: UILongPressGestureRecognizer) {
        
        let lokasiTap = gestureReconizer.location(in: mapView)
        let koordinatTap = mapView.convert(lokasiTap,toCoordinateFrom: mapView)
        
        // Add annotation:
        if mapView.annotations.count <= 1 {
            let anotasi = MKPointAnnotation()
            anotasi.coordinate = koordinatTap
            anotasi.title = "\(koordinatTap.latitude), \(koordinatTap.longitude)"
            mapView.addAnnotation(anotasi)
        }
        
    }

}

