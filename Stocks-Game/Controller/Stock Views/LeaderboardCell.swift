//
//  LeaderboardCell.swift
//  Stocks-Game
//
//  Created by Fatih Ak on 11/27/18.
//  Copyright © 2018 Fatih Ak. All rights reserved.
//

import UIKit

class LeaderboardCell: UITableViewCell {

    @IBOutlet var rankLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var changeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.rankLabel.text = ""
        self.usernameLabel.text = ""
        self.changeLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
