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
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var photoViewConstraints: NSLayoutConstraint!
    
    //Variables
    //1000 méter széles kör a user köröl
    let regionRadious: Double = 1000
    var screenSize = UIScreen.main.bounds
    var locationManager = CLLocationManager()
    var spinner: UIActivityIndicatorView?
    var downloadLbl: UILabel?
    var collectionview: UICollectionView!
    var cellId = "photoCell"
    var flowLayout = UICollectionViewFlowLayout()
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
        addGestures()
        
        collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: flowLayout)
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        collectionview.register(PhotoCell.self, forCellWithReuseIdentifier: cellId)
        self.photoView.addSubview(collectionview!)
    }
    

    func addActivityIndicator(){
        spinner = UIActivityIndicatorView()
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 150 )
        spinner?.color = #colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1)
        spinner?.startAnimating()
        self.collectionview?.addSubview(spinner!)
    }
    
    func removeActivityIndicator(){
        //Ha már van spinner akkor el kell távolítani
        if spinner != nil{
            spinner?.removeFromSuperview()
        }
    }
    
    func addDownloadLbl(){
        downloadLbl = UILabel()
        downloadLbl?.textColor = #colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1)
        downloadLbl?.font = UIFont.systemFont(ofSize: 16)
        downloadLbl?.frame = CGRect(x: (screenSize.width / 2) - 120 , y: 175, width: 240, height: 40)
        downloadLbl?.textAlignment = .center
        downloadLbl?.text = "12/24 photos downloaded"
        self.collectionview?.addSubview(downloadLbl!)
    }
    func removeDownloadLbl(){
        if downloadLbl != nil{
            downloadLbl?.removeFromSuperview()
        }
    }
    
    func animateViewUp(){
        self.photoViewConstraints.constant = 300
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func animateViewDown(){
        self.photoViewConstraints.constant = 1
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    @objc func handleDoubleTap(sender: UITapGestureRecognizer){
        removeAnnotation()
        removeActivityIndicator()
        removeDownloadLbl()
        
        animateViewUp()
        addActivityIndicator()
        addDownloadLbl()
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
//Gestures
extension CityVC {
    func addGestures(){
        let doublePin = UITapGestureRecognizer(target: self, action: #selector(CityVC.handleDoubleTap(sender:)))
        doublePin.delegate = self
        doublePin.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doublePin)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.down:
                animateViewDown()
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
}
//UICollectionView
extension CityVC: UICollectionViewDelegate, UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionview.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? PhotoCell else { return UICollectionViewCell() }
        return cell
    }
}
