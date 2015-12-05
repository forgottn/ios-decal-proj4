//
//  MainGameListTableViewCell.swift
//  FGCNetwork
//
//  Created by Peter Duong on 11/22/15.
//  Copyright © 2015 Peter Duong. All rights reserved.
//

import UIKit

class MainGameListTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.frame = CGRectMake(0, 0, (self.imageView?.frame.size.width)!, (self.imageView?.frame.size.height)!)
    }

}
