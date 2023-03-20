//
//  config.swift
//  RADIOBOX
//
//  Created by DEVS on 17.08.2020.
//  Copyright © 2020 Simpleapp. All rights reserved.
//

import UIKit


var APP_ID = "8HwHkzcOUZ3wFZvtZqb8VzRZ3taaGR9eJiBzGf90"
var CLIENT_KEY = "4OSczvFhDTcNwgUmxXkVn7vKMDK1bUQQsyLG7TaW"

var AD_BANNER_ID  = "ca-app-pub-3940256099942544/2934735716"

let DEF_IMG  = "https://images.unsplash.com/photo-1583944000409-00dd0ba1a873?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80"
let kDebugLog                        = true
let APPLE_IMAGE                      = true   // on / off image cover
let GLOBAL_CATEGORY = [Categorys]()
let GLOBAL_CAT = Categorys()






struct AppUtility {

    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {

        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }

    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {

        self.lockOrientation(orientation)

        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }

}
