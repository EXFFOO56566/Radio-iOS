//
//  SettingViewController.swift
//  RADIOBOX
//
//  Created by DEVS on 18.08.2020.
//  Copyright © 2020 Simpleapp. All rights reserved.
//

import UIKit
import Parse

class SettingViewController: UIViewController {
    
    @IBOutlet weak var login: UIButton!
    
    
    var isLogin: Bool!
    
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = User.current()
        
        if(user != nil){
            
            login.setTitle("Logout", for: .normal)
            isLogin = true
        } else {
            
            login.setTitle("Login", for: .normal)
            isLogin = false
        }
        
        login.layer.cornerRadius = 10
        
        
    }
    
    @IBAction func login(_ sender: Any) {
        
        if(isLogin){
            
            PFUser.logOut()
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "tab") as! TabViewController
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            
            
            
        } else{
            
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "login") as! LoginViewController
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            
        }
        
        
        
        
        
        
        
        
    }
    
    
    
    
}
