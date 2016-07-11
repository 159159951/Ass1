//
//  MovieCell.swift
//  Ass1
//
//  Created by HuyTTQ on 7/10/16.
//  Copyright © 2016 HuyTTQ. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var overviewLable: UILabel!
    @IBOutlet weak var posterImgView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
