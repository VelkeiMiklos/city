//
//  PhotoVC.swift
//  city
//
//  Created by Velkei Miklós on 2017. 11. 17..
//  Copyright © 2017. NeonatCore. All rights reserved.
//

import UIKit

class PhotoVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var photoImg: UIImageView!
    var passedImg: UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        photoImg.image = passedImg
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(PhotoVC.handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
        
    }
    
    @objc func handleDoubleTap(){
        dismiss(animated: true, completion: nil)
    }
    func initView(image: UIImage){
        self.passedImg = image
    }
    
}
