//
//  TopViewController.swift
//  RADIOBOX
//
//  Created by DEVS on 18.08.2020.
//  Copyright © 2020 Simpleapp. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage
import GoogleMobileAds

class TopViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tbleView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var allRadio = [Radio]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tbleView.dataSource = self
        tbleView.delegate = self
        
        bannerView.adUnitID = AD_BANNER_ID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        getTop()
        AppUtility.lockOrientation(.portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AppUtility.lockOrientation(.all)
        
    }
    
    func getTop(){
        
        self.allRadio.removeAll()
        
        let query = Radio.query()
        query?.includeKey("user")
        query?.order(byDescending: "allrating")
        query?.findObjectsInBackground(block: { (object, error) in
            if (error == nil){
                
                self.allRadio = object as! [Radio]
                self.tbleView.reloadData()
                
            }
            
        })
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(self.allRadio.count == 0){
            
        } else {
            
            return self.allRadio.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "radio") as! RadioTableViewCell
        
        let r = allRadio[indexPath.row].allrating
        
        cell.titleText.text = allRadio[indexPath.row].name.uppercased()
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
        
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "rdv") as! RadiosViewController
        vc.radio = allRadio[indexPath.row]
        
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
        
    }
    
    
    
    
    
}
