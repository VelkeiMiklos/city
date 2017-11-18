//
//  Constants.swift
//  city
//
//  Created by Velkei Miklós on 2017. 11. 17..
//  Copyright © 2017. NeonatCore. All rights reserved.
//

import Foundation

var CO_ANNOTATION_ID = "customAnnotation"
var CO_CELL_ID = "photoCell"
var CO_PHOTO_VC = "PhotoVC"
let apiKey = "c9b6dc4a2aef446db8ecab5294e8bd96"

func flickrUrl(forApiKey key: String, withAnnotation annotation: CustomAnnotation, andNumberOfPhotos number: Int) ->String{
    let url =  "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
    print(url)
    return url
}
