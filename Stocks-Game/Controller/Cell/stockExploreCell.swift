//
//  stockExploreCell.swift
//  Stocks-Game
//
//  Created by Fatih Ak on 11/29/18.
//  Copyright © 2018 Fatih Ak. All rights reserved.
//

import UIKit

class stockExploreCell: UITableViewCell {

    @IBOutlet var stockSymbolLabel: UILabel!
    
    @IBOutlet var changeLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
