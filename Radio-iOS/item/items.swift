//
//  items.swift
//  RADIOBOX
//
//  Created by DEVS on 17.08.2020.
//  Copyright © 2020 Simpleapp. All rights reserved.
//

import UIKit
import Parse

class Categorys: PFObject,PFSubclassing{
    
    @NSManaged var name: String
    
    static func parseClassName() -> String {
        return "Category"
    }
}

class Radio: PFObject, PFSubclassing{
    
    @NSManaged var logo: PFFileObject
    @NSManaged var stream: String
    @NSManaged var name: String
    @NSManaged var user: User
    @NSManaged var rating : NSNumber
    @NSManaged var voiting : NSNumber
    @NSManaged var allrating: NSNumber
    @NSManaged var category: Categorys
    @NSManaged var approved : Bool
    
    
    
    
    static func parseClassName() -> String {
        return "Radio"
    }
}

class User: PFUser {
    
    @NSManaged  var nickname: String?
    @NSManaged var photo : PFFileObject
    @NSManaged var player_id: String
    @NSManaged var is_Admin : Bool
    
    
    class func parseClassName() -> String! {
        return "User"
    }
}

class Like : PFObject, PFSubclassing{
    
    @NSManaged var radio: Radio
    @NSManaged var user: User
    
    
    
    static func parseClassName() -> String {
        return "Like"
    }
}

class Rating : PFObject, PFSubclassing{
    
    @NSManaged var radio: Radio
    @NSManaged var user: User
    
    static func parseClassName() -> String {
        return "Rating"
    }
}
    
class Complaint : PFObject, PFSubclassing{
        
    @NSManaged var type: String
    @NSManaged var radio: Radio
    @NSManaged var user: User
        
        
        
    static func parseClassName() -> String {
            return "Complaint"
     }
    
}
