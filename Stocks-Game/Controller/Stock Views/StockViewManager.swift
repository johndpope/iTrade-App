//
//  StockViewManager.swift
//  Stocks-Game
//
//  Created by Fatih Ak on 11/4/18.
//  Copyright © 2018 Fatih Ak. All rights reserved.
//

import UIKit

class StockViewManager: UIViewController {

    
    var chosenTab: Int = 0
    var data: [String: Any] = [:]
    var news: [[String: Any]] = [[:]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.chosenTab == 0{
            performSegue(withIdentifier: "showData", sender: self)
        }else if self.chosenTab == 1{
            performSegue(withIdentifier: "showNews", sender: self)
        }else{
            performSegue(withIdentifier: "showTrade", sender: self)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showData" {
            if let dest = segue.destination as? DataViewController {
                dest.data = self.data
            }
        }
        if segue.identifier == "showNews" {
            if let dest = segue.destination as? NewsViewController {
                dest.news = self.news
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
