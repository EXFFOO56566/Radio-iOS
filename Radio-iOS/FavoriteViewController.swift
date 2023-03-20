//
//  FavoriteViewController.swift
//  RADIOBOX
//
//  Created by DEVS on 19.08.2020.
//  Copyright © 2020 Simpleapp. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage
import Parse
import GoogleMobileAds


class FavoriteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    
    @IBOutlet weak var tbleView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var allRadio = [Radio]()
    var allFavorite = [Like]()
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = User.current()
        
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
        
        let query = Like.query()
        query?.whereKey("user", equalTo: user!)
        query?.includeKey("user")
        query?.includeKey("radio")
        query?.findObjectsInBackground(block: { (object, error) in
            if (error == nil){
                
                self.allFavorite = object  as! [Like]
                for like in self.allFavorite{
                    self.allRadio.append(like.radio)
                    
                }
                
                self.tbleView.reloadData()
                
            }
            
        })
        
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
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
        
        
        
        cell.titleText.text = allRadio[indexPath.row].name.uppercased()
        
        
        do {
            cell.userName.text = try allRadio[indexPath.row].user.fetchIfNeeded().object(forKey: "nickname") as? String
        } catch{
            print(error)
        }
        
        let voiting =  allRadio[indexPath.row].voiting as NSNumber
        
        if(voiting == 0){
            
            cell.rbar.value = 0
        } else {
            
            let r = allRadio[indexPath.row].allrating
            
            cell.rbar.value = CGFloat(truncating: r)
        }
        
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            
            
            allRadio.remove(at: indexPath.row)
            tbleView.deleteRows(at: [indexPath], with: .fade)
            
            let lavz = allFavorite[indexPath.row]
            lavz.deleteInBackground { (ok, error) in
            }
        }
    }
    
    
    
}
