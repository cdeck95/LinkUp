//
//  AppsTableViewCell.swift
//  AddMe
//
//  Created by Christopher Deck on 2/27/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit

class AppsTableViewCell: UITableViewCell {

    @IBInspectable var cornerRadius: CGFloat = 2
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 3
    @IBInspectable var shadowColor: UIColor? = UIColor.gray
    @IBInspectable var shadowOpacity: Float = 0.3
    @IBOutlet weak var NameLabel: UILabel!
    var id:Int!
   
    @IBOutlet weak var appSwitch: UISwitch!
    @IBOutlet weak var appImage: UIImageView!
    
    override func awakeFromNib() {
        print("AppTableViewCell.swift awakeFromNib()")
        super.awakeFromNib()
        // Initialization code
        self.bringSubview(toFront: appSwitch)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        print("AppTableViewCell.swift setSelected()")
        super.setSelected(selected, animated: animated)
        
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        
        layer.masksToBounds = false
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }
}

