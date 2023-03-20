//
//  AddRadioViewController.swift
//  RADIOBOX
//
//  Created by DEVS on 18.08.2020.
//  Copyright © 2020 Simpleapp. All rights reserved.
//

import UIKit
import Parse
import CRNotifications
import GoogleMobileAds

class AddRadioViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var categoryBtn: UIButton!
    @IBOutlet weak var btnPublish: UIButton!
    @IBOutlet weak var addImage: UIButton!
    @IBOutlet weak var radioName: UITextField!
    @IBOutlet weak var urlRadio: UITextField!
    @IBOutlet weak var radioCover: UIImageView!
      @IBOutlet weak var bannerView: GADBannerView!
    
    
    
    
    let regularFont = UIFont.systemFont(ofSize: 16)
    let boldFont = UIFont.boldSystemFont(ofSize: 16)
    
    var allCategory = [Categorys]()
    var namec = [String]()
    var category:Categorys!
    
    var albumPhoto = UIImagePickerController()
    var photoimage: UIImage!
    var parseFile: PFFileObject!
    
    
    var user : User!
    var isLogin: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView.adUnitID = AD_BANNER_ID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        radioName.attributedPlaceholder = NSAttributedString(string: "radio name",attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        urlRadio.attributedPlaceholder = NSAttributedString(string: "url radio stream",attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        addImage.layer.cornerRadius = 5
        categoryBtn.layer.cornerRadius = 5
        btnPublish.layer.cornerRadius = 5
        
        albumPhoto.delegate = self
        
        self.setupToHideKeyboardOnTapOnView()
        
        user = User.current()
        
        if user != nil {
            
            isLogin = true
            
        } else {
            
            
            isLogin = false
            let al = Alertz()
            al.errorAlert()
            
            
            
                       DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                           
                           let vc = self.storyboard!.instantiateViewController(withIdentifier: "tab") as! TabViewController
                                      vc.modalPresentationStyle = .fullScreen
                                      self.present(vc, animated: true, completion: nil)
                       }
            
        }
        
        getCategory()
        
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
            self.radioCover.image = photoimage!
            self.changez()
            picker.dismiss(animated: true, completion: nil)
        } else if let originalImage = info[.originalImage] as? UIImage {
            photoimage = originalImage
            self.changez()
            self.radioCover.image = photoimage!
            picker.dismiss(animated: true, completion: nil)
        }
        
    }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func changez(){
        
        let imageData = self.photoimage.jpegData(compressionQuality: 50)
        
        ERProgressHud.sharedInstance()?.show(withTitle: "Save photo...")
        
        
        parseFile = PFFileObject.init(name: "user_file.jpg", data: imageData!)
        parseFile.saveInBackground { (ok, error) in
            
            
            
            ERProgressHud.sharedInstance()?.hide()
        }
        
        
    }
    
    func getCategory(){
        
        let query = Categorys.query()
        query?.order(byAscending: "createdAt")
        query?.findObjectsInBackground(block: { (object, error) in
            
            if (error == nil){
                
                
                
                self.allCategory = object as! [Categorys]
                
                for category in self.allCategory{
                    
                    
                    self.namec.append(category.name)
                }
                
                
                
            }
            
        })
        
        
    }
    
    @IBAction func selectCategory(_ sender: UIButton) {
        
        let greenColor = sender.backgroundColor
        
        let theme = YBTextPickerAppearanceManager.init(
            pickerTitle         : "Pick a category",
            titleFont           : boldFont,
            titleTextColor      : .white,
            titleBackground     : nil,
            searchBarFont       : regularFont,
            searchBarPlaceholder: "Search category",
            closeButtonTitle    : "Cancel",
            closeButtonColor    : .darkGray,
            closeButtonFont     : regularFont,
            doneButtonTitle     : "Okay",
            doneButtonColor     : greenColor,
            doneButtonFont      : boldFont,
            checkMarkPosition   : .Right,
            itemCheckedImage    : nil,
            itemUncheckedImage  : nil,
            itemColor           : .white,
            itemFont            : regularFont
        )
        
        let arrTheme = namec
        let picker = YBTextPicker.init(with: arrTheme, appearance: theme, onCompletion: { (selectedIndexes, selectedValues) in
            
            if let selectedValue = selectedValues.first{
                self.categoryBtn.setTitle(selectedValue, for: .normal)
                
                let point = selectedIndexes[0]
                self.category = self.allCategory[point]
                
            }else{
                self.categoryBtn.setTitle("Select category", for: .normal)
            }
        }, onCancel: {
            
        })
        picker.show(withAnimation: .FromBottom)
        
        
        
    }
    
    
    @IBAction func publishRadio(_ sender: UIButton) {
        
        if(isLogin){
            
            ERProgressHud.sharedInstance()?.show(withTitle: "Record data...")
            
            let radio = Radio()
            radio.name = radioName.text!
            radio.stream = urlRadio.text!
            radio.logo = parseFile
            radio.approved = false
            radio.category = category
            radio.voiting = 0
            radio.rating = 0
            radio.allrating = 0
            radio.user = user
            radio.saveInBackground { (ok, error) in
                
                if (error == nil){
                    
                    ERProgressHud.sharedInstance()?.hide()
                    
                    let vc = self.storyboard!.instantiateViewController(withIdentifier: "tab") as! TabViewController
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                    
                } else {
                    
                    
                    ERProgressHud.sharedInstance()?.hide()
                }
            }
            
        } else {
            
            CRNotifications.showNotification(type: CRNotifications.error, title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("first", comment: ""), dismissDelay: 3)
            
        }
        
    }
    
    
}
