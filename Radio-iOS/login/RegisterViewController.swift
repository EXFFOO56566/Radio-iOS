//
//  RegisterViewController.swift
//  Transistor-s
//
//  Created by Sonor on 25.01.2020.
//  Copyright © 2020 Simpleapp. All rights reserved.
//

import UIKit
import SCLAlertView
import Parse

class RegisterViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var register: UIButton!
    @IBOutlet weak var vatar: UIImageView!
    
    var albumPhoto = UIImagePickerController()
    var photoimage: UIImage!
    var parseFile: PFFileObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.username.delegate = self
        self.password.delegate = self
        self.email.delegate = self
        self.setupToHideKeyboardOnTapOnView()
        
        albumPhoto.delegate = self
        
    }
    
    @IBAction func addPhoto(){
           
           chooseAlbum()
       }
    
    func chooseAlbum(){
           
           print("Select  photo")
           
           albumPhoto.allowsEditing = false
           albumPhoto.sourceType = .photoLibrary
           albumPhoto.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
           present(albumPhoto, animated: true, completion: nil)
           
       }
    
 
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        
        if let editedImage = info[.editedImage] as? UIImage {
            photoimage = editedImage
            self.vatar.image = photoimage!
            self.changez()
            picker.dismiss(animated: true, completion: nil)
        } else if let originalImage = info[.originalImage] as? UIImage {
            photoimage = originalImage
            self.changez()
            self.vatar.image = photoimage!
            picker.dismiss(animated: true, completion: nil)
        }

    }
    
  
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func changez(){
        
        let imageData = self.photoimage.pngData()
        
        ERProgressHud.sharedInstance()?.show(withTitle: "Save photo...")
        
        
        parseFile = PFFileObject.init(name: "user_file.png", data: imageData!)
        parseFile.saveInBackground { (ok, error) in
            
            ERProgressHud.sharedInstance()?.hide()
        }
    
    }
    
    @IBAction func reg_action(_ sender: Any) {
        
        ERProgressHud.sharedInstance()?.show(withTitle: "Record data...")
        
        if ((self.username.text?.isEmpty)! || (self.password.text?.isEmpty)! || (self.email.text?.isEmpty)!){
            self.alert(messag: "Fill all necessary fields")
            ERProgressHud.sharedInstance()?.hide()
        } else {
            
            let user = User()
            user.nickname =  "The radio user"
            user.username = self.username.text
            user.password = self.password.text
            user.email = self.email.text
            user.photo = parseFile
            user.player_id = "iphone_user"
            user.signUpInBackground { (us, error) in
                
                if (error == nil){
                    
                    ERProgressHud.sharedInstance()?.hide()
                    
                    let vc = self.storyboard!.instantiateViewController(withIdentifier: "tab") as! TabViewController
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                    
                } else {
                    
                    self.alert(messag: (error?.localizedDescription)!)
                    ERProgressHud.sharedInstance()?.hide()
                }
            }
            
        }
        
        
    }
    
    func alert (messag: String){
        
        let alertView = SCLAlertView()
        alertView.showSuccess("Registration", subTitle: messag)
        
        
    }
    
    
    @IBAction func backs (_ sender : Any){
        
        self.dismiss(animated: true) {
            
        }
    }
    
    
}
