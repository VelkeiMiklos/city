//
//  ViewController.swift
//  city
//
//  Created by Velkei Miklós on 2017. 11. 14..
//  Copyright © 2017. NeonatCore. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
class CityVC: UIViewController, UIGestureRecognizerDelegate {

    //Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    
    //Variables
    //1000 méter széles kör a user köröl
    let regionRadious: Double = 1000
    var locationManager = CLLocationManager()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Ha nincsen engedély akkor kérni kell
        if CLService.instance.getPermission() == false {
            showAcessDeniedAlert()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        CLService.instance.authorize()
        let doublePin = UITapGestureRecognizer(target: self, action: #selector(CityVC.handleDoubleTap(sender:)))
        doublePin.delegate = self
        doublePin.numberOfTapsRequired = 2
        view.addGestureRecognizer(doublePin)
    }
    
    @objc func handleDoubleTap(sender: UITapGestureRecognizer){
        removeAnnotation()
        
        
        print("double tapped")
        //Hová érint
        let touchPoint = sender.location(in: mapView)
        print(touchPoint)
        //koordinátává alakítás
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = CustomAnnotation(coordinate: touchCoordinate, id: "customAnnotation")
        mapView.addAnnotation(annotation)
    }
    
    func removeAnnotation(){
        self.mapView.annotations.forEach {
            if !($0 is MKUserLocation) {
                self.mapView.removeAnnotation($0)
            }
        }
    }
    
    @IBAction func centerBtnWasPressed(_ sender: Any) {
        if CLService.instance.getPermission() == false {
            showAcessDeniedAlert()
        }
        centerMapOnUserLocation()
    }
}

//Ha nincsen megadva az engedély akkor felugrik egy pop-up amivel a beállításokra ugrik és meg lehet adni az engedélyt
extension CityVC{
    func showAcessDeniedAlert() {
        let alertController = UIAlertController(title: "Location Accees Requested",
                                                message: "The location permission was not authorized. Please enable it in Settings to continue.",
                                                preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (alertAction) in
            
            // Megnyitja a settings-t
            if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(appSettings as URL)
            }
        }
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}
extension CityVC: MKMapViewDelegate{
    
    func centerMapOnUserLocation(){
        //A jelenlegi koordináta lekérdezése
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadious * 2.0, regionRadious * 2.0)
        //1000m kör a user körül
        mapView.setRegion(coordinateRegion, animated: true)
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //A felhasználó helyzetét mutatót nem kell lecserélni
        if annotation is MKUserLocation{
            return nil
        }
        
        let annotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "customAnnotation")
        annotation.pinTintColor = #colorLiteral(red: 0.9124692082, green: 0.6528410316, blue: 0.1888206005, alpha: 1)
        annotation.animatesDrop = true
        return annotation
    }
}
extension CityVC: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}
