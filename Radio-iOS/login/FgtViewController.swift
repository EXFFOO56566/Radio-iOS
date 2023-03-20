//
//  FgtViewController.swift
//  Transistor-s
//
//  Created by Sonor on 31.01.2020.
//  Copyright © 2020 Simpleapp. All rights reserved.
//

import UIKit
import Parse
import CRNotifications

class FgtViewController: UIViewController {
    
    @IBOutlet weak var mailTxt: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func backs (_ sender : Any){
        
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func resets(_ sender : Any){
        PFUser.requestPasswordResetForEmail(inBackground: mailTxt.text!) { (ok, eror) in
            
            if eror == nil {
                
                CRNotifications.showNotification(type: CRNotifications.success, title: "Success!", message: "Email sended.", dismissDelay: 3, completion: {
                    
                    let vc = self.storyboard!.instantiateViewController(withIdentifier: "tab") as! TabViewController
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                })
            } else {
                
                CRNotifications.showNotification(type: CRNotifications.error, title: "Opss...!", message: eror!.localizedDescription, dismissDelay: 3, completion: {
                    
                    let vc = self.storyboard!.instantiateViewController(withIdentifier: "tab") as! TabViewController
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                })
            }
            
        }
    }
    
}
