//
//  CLService.swift
//  city
//
//  Created by Velkei Miklós on 2017. 11. 14..
//  Copyright © 2017. NeonatCore. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
class CLService: NSObject{
    
    static let instance = CLService()
    var locationManager = CLLocationManager()
    
    //Hozzáférés kérése + info.plist
    func authorize(){
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }
}
extension CLService: CLLocationManagerDelegate {
    //Auth. állapot lekérdezése
    func getPermission() -> Bool {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            return true
        case .authorizedWhenInUse:
            return true
        case .denied:
            return false
        case .restricted:
            return false
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            return getPermission()
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
}
