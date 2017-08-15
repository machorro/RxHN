//
//  HNCommentCell.swift
//  RxHNDemo
//
//  Created by humbertog on 2017-08-14.
//  Copyright © 2017 humbertog. All rights reserved.
//

import UIKit

class HNCommentCell: UITableViewCell {
    
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var comment: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
