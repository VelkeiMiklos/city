//
//  ViewController.swift
//  city
//
//  Created by Velkei Miklós on 2017. 11. 14..
//  Copyright © 2017. NeonatCore. All rights reserved.
//

import UIKit
import MapKit
class CityVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Ha nincsen engedély akkor kérni kell
        if CLService.instance.getPermission() == false {
            showAcessDeniedAlert()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CLService.instance.authorize()
        // Do any additional setup after loading the view, typically from a nib.
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
