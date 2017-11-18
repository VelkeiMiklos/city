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
    var flowLayout = UICollectionViewFlowLayout()
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    
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
        collectionview.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        collectionview.register(PhotoCell.self, forCellWithReuseIdentifier: CO_CELL_ID)
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
        downloadLbl?.text = "Downloading..."
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
        DataService.instance.cancelAllSessions()
        self.photoViewConstraints.constant = 1
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    @objc func handleDoubleTap(sender: UITapGestureRecognizer){
        imageUrlArray = []
        imageArray = []
        collectionview.reloadData()
        removeAnnotation()
        removeActivityIndicator()
        removeDownloadLbl()
        DataService.instance.cancelAllSessions()
        
        animateViewUp()
        addActivityIndicator()
        addDownloadLbl()
        print("double tapped")
        //Hová érint
        let touchPoint = sender.location(in: mapView)
        print(touchPoint)
        //koordinátává alakítás
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = CustomAnnotation(coordinate: touchCoordinate, id: CO_ANNOTATION_ID)
        mapView.addAnnotation(annotation)
        
        let url = flickrUrl(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhotos: 40)
        print(url)
        DataService.instance.downloadUrls(url: url) { (isSuccess, returnedUrls) in
            if isSuccess{
                self.imageUrlArray = returnedUrls!
               // print(self.imageUrlArray)
                for image in self.imageUrlArray{
                    DataService.instance.downloadImage(image, handler: { (isImageSuccess, returnedImage) in
                        if isImageSuccess{
                            self.imageArray.append(returnedImage)
                            self.downloadLbl?.text = "\(self.imageArray.count)/40 images downloaded"
                            if self.imageArray.count == self.imageUrlArray.count{
                                self.spinner?.removeFromSuperview()
                                self.downloadLbl?.removeFromSuperview()
                                self.collectionview!.reloadData()
                            }
                        }
                    })
                }

            }
        }
        
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
        
        let annotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: CO_ANNOTATION_ID)
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
        return imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionview.dequeueReusableCell(withReuseIdentifier: CO_CELL_ID, for: indexPath) as? PhotoCell else { return UICollectionViewCell() }
        let imageIndex = imageArray[indexPath.row]
        let imageView = UIImageView(image: imageIndex)
        cell.addSubview(imageView)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let photoVC = storyboard?.instantiateViewController(withIdentifier: CO_PHOTO_VC) as? PhotoVC else{return}
        photoVC.initView(image: imageArray[indexPath.row])
        present(photoVC, animated: true, completion: nil)
        
    }
    
}
