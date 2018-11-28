//
//  PortfolioCell.swift
//  Stocks-Game
//
//  Created by Fatih Ak on 11/18/18.
//  Copyright © 2018 Fatih Ak. All rights reserved.
//

import UIKit

class PortfolioCell: UITableViewCell {

    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var symbolLabel: UILabel!
    @IBOutlet var sharesLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
