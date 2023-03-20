//
//  AppleHelpers.swift
//  Global
//
//  Created by Sonor on 03.10.2019.
//  Copyright © 2019 Appteve. All rights reserved.
//

import UIKit
import Alamofire

class AppleHelpers: NSObject {
    
    
    func getPreviewUrl(din:String, completion:@escaping( _ resp: String, _ found: Bool, _ bigArtvork: String) -> Void){
        
        let queryURL = String(format: "https://itunes.apple.com/search?term=%@&limit=1", din)
        let escapedURL = queryURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!
        
        Alamofire.request( escapedURL, method: .get)
            .responseJSON { response in
                
                let data = response.result.value as! NSDictionary
                
                let countFind = data.value(forKey: "resultCount") as! Int
                if (countFind > 0){
                    
                    let resultArray = data.value(forKey: "results") as! NSArray
                    let result = resultArray[0] as! NSDictionary
                    let artwork = result.value(forKey: "artworkUrl100") as! String
                    
                    let bigArtwork = artwork.replacingOccurrences(of: "100", with: "800")
                    let musicUrl  = result.value(forKey: "trackViewUrl") as! String
                    
                    completion (musicUrl, true, bigArtwork)
                    
                } else {
                    
                    completion ("1", false,"none")
                    
                    
                }
                
        }
        
        
        
    }
    
    func getAppleMusic(din:String, completion:@escaping( _ resp: String, _ found: Bool, _ bigArtvork: String) -> Void){
           
           let queryURL = String(format: "https://itunes.apple.com/search?term=%@&limit=1", din)
           let escapedURL = queryURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!
           
           Alamofire.request( escapedURL, method: .get)
               .responseJSON { response in
                   
                   let data = response.result.value as! NSDictionary
                   
                   let countFind = data.value(forKey: "resultCount") as! Int
                   if (countFind > 0){
                       
                       let resultArray = data.value(forKey: "results") as! NSArray
                       let result = resultArray[0] as! NSDictionary
                       let artwork = result.value(forKey: "artworkUrl100") as! String
                       
                       let bigArtwork = artwork.replacingOccurrences(of: "100", with: "800")
                       let musicUrl  = result.value(forKey: "trackViewUrl") as! String
                       
                       completion (musicUrl, true, bigArtwork)
                       
                   } else {
                       
                       completion ("1", false,"none")
                       
                       
                   }
                   
           }
           
           
           
       }
    
    
    
}
