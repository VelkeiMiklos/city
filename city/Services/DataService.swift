//
//  DataService.swift
//  city
//
//  Created by Velkei Miklós on 2017. 11. 17..
//  Copyright © 2017. NeonatCore. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
class DataService{
    static let instance = DataService()
    //https://farm5.staticflickr.com/4557/26688844999_95015db293_h_d.jpg
    //    "photos":{
    //    "page":1,
    //    "pages":931,
    //    "perpage":40,
    //    "total":"37232",
    //    "photo":[
    //    {
    //    "id":"38421241286",
    //    "owner":"18713525@N00",
    //    "secret":"2a06e83fe4",
    //    "server":"4526",
    //    "farm":5,
    //    "title":"nov 16th",
    //    "ispublic":1,
    //    "isfriend":0,
    //    "isfamily":0
    //    },
    //    {
    //    "id":"38473105691",
    //    "owner":"110717344@N02",
    //    "secret":"4c3a94478d",
    //    "server":"4578",
    //    "farm":5,
    //    "title":"",
    //    "ispublic":1,
    //    "isfriend":0,
    //    "isfamily":0
    //    },
    
    
    
    func downloadUrls(url: String, handler: @escaping(_ success: Bool, _ urlArray :[String]?)->()){
        var urlArray = [String]()
        Alamofire.request(url).responseJSON { (response) in
            if response.result.error == nil{
                guard let json = response.value as? Dictionary<String,Any> else { return }
                //print(phototDict)
                let photosDict = json["photos"] as! Dictionary<String, AnyObject>
                let photoArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
                for photo in photoArray{
                    let url = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                    urlArray.append(url)
                }
                handler(true, urlArray)
            }else{
                handler(false, nil)
                debugPrint(response.result.error as Any)
                
            }
        }
    }
    
    func downloadImage(_ url: String, handler: @escaping(_ success: Bool, _ image: UIImage)->()){
        
        Alamofire.request(url).responseImage(completionHandler: { (response) in
            guard let image = response.value else { return }
           handler(true,image)
        })

        
    }
    func cancelAllSessions() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach({ $0.cancel() })
            downloadData.forEach({ $0.cancel() })
        }
    }
}

