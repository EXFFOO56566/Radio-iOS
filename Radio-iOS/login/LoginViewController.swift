//
//  LoginViewController.swift
//  Transistor-s
//
//  Created by Sonor on 25.01.2020.
//  Copyright © 2020 Simpleapp. All rights reserved.
//

import UIKit
import Parse
import SCLAlertView


class LoginViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var login_btn: UIButton!
    @IBOutlet weak var forgot_btn: UIButton!
    @IBOutlet weak var register_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupToHideKeyboardOnTapOnView()
        
    }
    
    @IBAction func goToRegister(){
        
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "register") as! RegisterViewController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func logins(_ sender: Any) {
        
        ERProgressHud.sharedInstance()?.show(withTitle: "Record data")
        let username = self.username.text
        let password = self.password.text
        
        PFUser.logInWithUsername(inBackground: username!, password: password!, block: { (user, error) -> Void in
            
            if ((user) != nil) {
                
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "tab") as! TabViewController
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
                
            } else {
                
                self.alert(messag: (error?.localizedDescription)!)
            }
            ERProgressHud.sharedInstance()?.hide()
        })
    }
    
    @IBAction func backs (_ sender : Any){
        
        self.dismiss(animated: true) {
            
        }
    }
    
    func alert (messag: String){
        
        let alertView = SCLAlertView()
       
        alertView.showSuccess("Login", subTitle: messag)
        
        
        
    }
    
    @IBAction func forgots(_sender:Any){
        
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "fgt") as! FgtViewController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
   
    
}

extension UIViewController
{
    func setupToHideKeyboardOnTapOnView()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))

        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
