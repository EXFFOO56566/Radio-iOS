//
//  UserPrViewController.swift
//  RADIOBOX
//
//  Created by DEVS on 19.08.2020.
//  Copyright © 2020 Simpleapp. All rights reserved.
//

import UIKit

class UserPrViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
              swipeDown.direction = .down
              self.view.addGestureRecognizer(swipeDown)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
           if gesture.direction == .right {
               print("Swipe Right")
           }
           else if gesture.direction == .left {
               print("Swipe Left")
           }
           else if gesture.direction == .up {
               print("Swipe Up")
           }
           else if gesture.direction == .down {
               print("Swipe Down")
               dismiss(animated: true, completion: nil)
           }
       }
   

}
