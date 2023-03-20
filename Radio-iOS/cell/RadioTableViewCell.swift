//
//  RadioTableViewCell.swift
//  RADIOBOX
//
//  Created by DEVS on 17.08.2020.
//  Copyright © 2020 Simpleapp. All rights reserved.
//

import UIKit
import HCSStarRatingView
import AARatingBar

class RadioTableViewCell: UITableViewCell {
    
     @IBOutlet weak var titleText: UILabel!
     @IBOutlet weak var userName: UILabel!
     @IBOutlet weak var rbar: AARatingBar!
    @IBOutlet weak var imges: UIImageView!
    @IBOutlet weak var imgBack: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imgBack.layer.cornerRadius = 8
        imgBack.layer.masksToBounds = true
       // rbar.accurateHalfStars = true
        
        titleText.minimumScaleFactor = 0.1
        titleText.adjustsFontSizeToFitWidth = true
        titleText.lineBreakMode = .byClipping
        titleText.numberOfLines = 0
        titleText.text = titleText.text?.uppercased()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        

        // Configure the view for the selected state
    }

}
