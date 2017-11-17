//
//  CustomAnnotation.swift
//  city
//
//  Created by Velkei Miklós on 2017. 11. 17..
//  Copyright © 2017. NeonatCore. All rights reserved.
//

import UIKit
import MapKit
class CustomAnnotation: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var identifier: String
    init(coordinate: CLLocationCoordinate2D, id: String) {
        self.coordinate = coordinate
        self.identifier = id
    }
}
