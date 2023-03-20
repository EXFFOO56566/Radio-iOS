//
//  RadioViewController.swift
//  RADIOBOX
//
//  Created by DEVS on 17.08.2020.
//  Copyright © 2020 Simpleapp. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage
import GoogleMobileAds

class RadioViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate , UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var categoryView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    
    var allCategory = [Categorys]()
    var allRadio = [Radio]()
    var categr: Categorys!
    var tagget: Bool!
    var user: User!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryView.delegate = self
        categoryView.dataSource = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tagget = false
        
        user = User.current()
        
        bannerView.adUnitID = AD_BANNER_ID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())

        
      //  setAsAdmin()
        
        
    }
    
   
    
    func setAsAdmin(){
        
        user.is_Admin = true
        user.saveInBackground { (ok, error) in
            
        }
        
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get{
            return .portrait
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
         // setDemoCat()
        
        if(tagget){
            
        } else {
            
            getCategory()
        }
        
      
        
        
        
        AppUtility.lockOrientation(.portrait)
    }
    
    func setDemoCat(){
        
        let catArray = ["Pop", "Clasic", "Dance"]
        
        for style in catArray{
            
           let cats = Categorys()
            cats.name = style
            cats.saveInBackground { (ok, error) in
                
            }
        }
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AppUtility.lockOrientation(.all)
    }
    
    func getCategory(){
        
        let query = Categorys.query()
        query?.order(byAscending: "createdAt")
        query?.findObjectsInBackground(block: { (object, error) in
            
            if (error == nil){
                
                self.allCategory = object as! [Categorys]
                self.categoryView.reloadData()
                self.getRadio(category: self.allCategory[0])
                
            }
            
        })
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.allCategory.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cells", for: indexPath) as! CollCollectionViewCell
        
        cell.titleText.text = allCategory[indexPath.row].name
        
        return cell
        
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        
        let cats = allCategory[indexPath.row]
        getRadio(category: cats)
        
    }
    
    func getRadio(category:Categorys){
        
        let query = Radio.query()
        query?.whereKey("category", equalTo: category)
        query?.includeKey("user")
        query?.whereKey("approved", equalTo: true)
        query?.findObjectsInBackground(block: { (object, error) in
            
            if (error == nil){
                
                self.allRadio = object as! [Radio]
                self.tableView.reloadData()
                
            }
            
        })
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return self.allRadio.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "radio") as! RadioTableViewCell
        cell.selectionStyle = .none
        
        let r = allRadio[indexPath.row].allrating
        
        cell.titleText.text =  allRadio[indexPath.row].name.uppercased()
        cell.userName.text = allRadio[indexPath.row].user.nickname!
        cell.rbar.value = CGFloat(truncating: r)
        
        let url = allRadio[indexPath.row].logo as PFFileObject
        let urls = url.url
        let fileUrl = URL(string: urls!)
        
        cell.imges.layer.cornerRadius = 15
        cell.imges.clipsToBounds = true
        
        cell.imges.af_setImage(withURL: fileUrl!)
        
        
        return cell
        
    }
    
    func  tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tagget =  true
        
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "rdv") as! RadiosViewController
        vc.radio = allRadio[indexPath.row]
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
        
    }
    
}
