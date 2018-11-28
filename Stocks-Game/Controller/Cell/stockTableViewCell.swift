//
//  stockTableViewCell.swift
//  Stocks-Game
//
//  Created by Fatih Ak on 10/23/18.
//  Copyright © 2018 Fatih Ak. All rights reserved.
//

import UIKit

class stockTableViewCell: UITableViewCell {

    @IBOutlet var stockNameLabel: UILabel!
    @IBOutlet var stockSymbolLabel: UILabel!
    @IBOutlet var stockPercentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
