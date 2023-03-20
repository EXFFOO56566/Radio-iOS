//
//  CollCollectionViewCell.swift
//  RADIOBOX
//
//  Created by DEVS on 17.08.2020.
//  Copyright © 2020 Simpleapp. All rights reserved.
//

import UIKit

class CollCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var imgBack: UIImageView!
    
    override func awakeFromNib() {
           super.awakeFromNib()
           // Initialization code
           
           imgBack.layer.cornerRadius = 8
           imgBack.layer.masksToBounds = true
       }
}
