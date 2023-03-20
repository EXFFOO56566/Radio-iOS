//
//  UserViewController.swift
//  RADIOBOX
//
//  Created by DEVS on 18.08.2020.
//  Copyright © 2020 Simpleapp. All rights reserved.
//

import UIKit
import Parse
import CRNotifications
import SPAlert
import SCLAlertView
import GoogleMobileAds

class UserViewController: UIViewController ,  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    @IBOutlet weak var changeNameBtn: UIButton!
    @IBOutlet weak var changePhotoBtn: UIButton!
    @IBOutlet weak var favBack: UIView!
    @IBOutlet weak var myRadioBack: UIView!
    @IBOutlet weak var userRadioBack: UIView!
    @IBOutlet weak var complBack: UIView!
    @IBOutlet weak var fvoriteBtn: UIButton!
    @IBOutlet weak var myRadioBtn: UIButton!
    @IBOutlet weak var userRadioBtn: UIButton!
    @IBOutlet weak var complaintBtn: UIButton!
    @IBOutlet weak var userTextName: UILabel!
    @IBOutlet weak var userAva: UIImageView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    
    
    
    var user: User!
    var isAdmin: Bool!
    
    var albumPhoto = UIImagePickerController()
    var photoimage: UIImage!
    var parseFile: PFFileObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = User.current()
        
        albumPhoto.delegate = self
        
        ui()
        
        if user == nil {
            
            let al = Alertz()
            al.errorAlert()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "tab") as! TabViewController
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
            
        } else {
            
            isAdmin = user.is_Admin
            userTextName.text = user.nickname
            let url = user.photo as PFFileObject
            let urls = url.url
            let fileUrl = URL(string: urls!)
            userAva.af_setImage(withURL: fileUrl!)
            
            if(!isAdmin){
                
                hideUI()
            }
            
        }
        
        bannerView.adUnitID = AD_BANNER_ID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        
    }
    
    @IBAction func changeNameUser(_ sender: Any) {
        
        let alert = SCLAlertView()
        let txt = alert.addTextField("Enter your name")
        alert.addButton("Save your name") {
            // print("Text value: \(txt.text)")
            
            self.user.nickname = txt.text
            self.user.saveInBackground { (ok, error) in
                
                self.userTextName.text = txt.text
                
            }
        }
        alert.showEdit("Edit name", subTitle: "")
        
    }
    
    @IBAction func changeAvatar(_ sender: Any) {
        
        chooseAlbum()
        
    }
    
    func chooseAlbum(){
        
        print("Select  photo")
        
        albumPhoto.allowsEditing = false
        albumPhoto.sourceType = .photoLibrary
        albumPhoto.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(albumPhoto, animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func changez(){
        
        let imageData = self.photoimage.jpegData(compressionQuality: 50)
        
        ERProgressHud.sharedInstance()?.show(withTitle: "Save photo...")
        
        
        parseFile = PFFileObject.init(name: "user_file.jpg", data: imageData!)
        parseFile.saveInBackground { (ok, error) in
            
            
            self.user.photo = self.parseFile
            self.user.saveInBackground { (ok, error) in
                
            }
            
            ERProgressHud.sharedInstance()?.hide()
        }
        
        
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[.editedImage] as? UIImage {
            photoimage = editedImage
            self.userAva.image = photoimage!
            self.changez()
            picker.dismiss(animated: true, completion: nil)
        } else if let originalImage = info[.originalImage] as? UIImage {
            photoimage = originalImage
            self.changez()
            self.userAva.image = photoimage!
            picker.dismiss(animated: true, completion: nil)
        }
        
    }
    
    
    
    func ui(){
        
        favBack.layer.cornerRadius = 15
        myRadioBack.layer.cornerRadius = 15
        userRadioBack.layer.cornerRadius = 15
        complBack.layer.cornerRadius = 15
        
        changeNameBtn.layer.cornerRadius = 10
        changePhotoBtn.layer.cornerRadius = 10
        
        fvoriteBtn.layer.cornerRadius = 10
        myRadioBtn.layer.cornerRadius = 10
        userRadioBtn.layer.cornerRadius = 10
        complaintBtn.layer.cornerRadius = 10
        
        userAva.layer.cornerRadius = 20
        userAva.layer.masksToBounds = true
        
        
        
        
    }
    
    func hideUI(){
        
        userRadioBack.isHidden = true
        complBack.isHidden = true
        
        
    }
    
    
    
}
