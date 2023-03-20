//
//  ComplaintViewController.swift
//  RADIOBOX
//
//  Created by DEVS on 20.08.2020.
//  Copyright © 2020 Simpleapp. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage


class ComplaintViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tbleView: UITableView!
    
    var allCompl = [Complaint]()
    var allRadio = [Radio]()
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = User.current()
        
        tbleView.dataSource = self
        tbleView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        getCompl()
        AppUtility.lockOrientation(.portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AppUtility.lockOrientation(.portrait)
        
    }
    
    func getCompl(){
        
        self.allCompl.removeAll()
        self.allRadio.removeAll()
        
        let query = Complaint.query()
        query?.includeKey("user")
        query?.includeKey("radio")
        query?.findObjectsInBackground(block: { (object, error) in
            
            if (error == nil){
                
                self.allCompl = object  as! [Complaint]
                for compl in self.allCompl{
                    
                    self.allRadio.append(compl.radio)
                }
                
                if(self.allRadio.count != 0){
                    self.tbleView.reloadData()
                }
                
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
        
        cell.titleText.text = allRadio[indexPath.row].name.uppercased()
        
        do {
            cell.userName.text = try allRadio[indexPath.row].user.fetchIfNeeded().object(forKey: "nickname") as? String
        } catch{
            print(error)
        }
        
        let r = allRadio[indexPath.row].allrating
        
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Hide") { (action, indexPath) in
            // delete item at indexPath
            
            let radio = self.allRadio[indexPath.row]
            radio.approved = false
            
            radio.saveInBackground(block: { (ok, error) in
                self.allRadio.remove(at: indexPath.row)
                self.tbleView.deleteRows(at: [indexPath], with: .fade)
            })
            
            
            
            let com = self.allCompl[indexPath.row]
            com.deleteInBackground { (ok, error) in
                
            }
            
        }
        
        return [delete]
    }
    
    
}


