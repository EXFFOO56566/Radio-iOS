//
//  Alertz.swift
//  RADIOBOX
//
//  Created by DEVS on 19.08.2020.
//  Copyright © 2020 Simpleapp. All rights reserved.
//

import UIKit
import SPAlert

class Alertz: NSObject {
    
    func errorAlert(){
        
        
        SPAlert.present(title: "The function is available only for registered users. Please signup or sign in", preset: .done)
    }
    
    func doneAlet(){
        
        /* let alertView = SPAlertView(title: "Done", message: nil, preset: SPAlertPreset.done)
              alertView.duration = 3
              alertView.present() */
        
    }
    
}
