//
//  NewsCell.swift
//  Stocks-Game
//
//  Created by Fatih Ak on 11/5/18.
//  Copyright © 2018 Fatih Ak. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {

    @IBOutlet var newsImage: UIImageView!
    @IBOutlet var headLineLabel: UILabel!
    
    let news: [String: Any] = [:]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
