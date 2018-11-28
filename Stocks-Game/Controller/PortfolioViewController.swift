//
//  PortfolioViewController.swift
//  Stocks-Game
//
//  Created by Fatih Ak on 11/16/18.
//  Copyright © 2018 Fatih Ak. All rights reserved.
//

import UIKit

class PortfolioViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var currentUser: CurrentUser? = nil
    
    @IBOutlet var balanceLabel: UILabel!
    @IBOutlet var stocksTableView: UITableView!
    @IBOutlet var dayChangeLabel: UILabel!
    @IBOutlet var dayPercentLabel: UILabel!
    @IBOutlet var dayChangeIcon: UIImageView!
    @IBOutlet var overallChangeLabel: UILabel!
    @IBOutlet var overallPercentLabel: UILabel!
    @IBOutlet var overallChangeIcon: UIImageView!
    
    var selectedStock: String = ""
    var sortedKeys: [String] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stocksTableView.delegate = self
        self.stocksTableView.dataSource = self
        
        self.sortedKeys = (self.currentUser?.getOrderedList().sorted(by: <))!
        
        self.currentUser?.getStockData{ success in
            guard success else { return }
            let currentWorth: Double = (self.currentUser?.currentWorth())!
            self.balanceLabel.text = currencyFormat(value: currentWorth)
            
            let increaseIcon: UIImage = UIImage(named: "increase.png")!
            let decreaseIcon: UIImage = UIImage(named: "decrease.png")!
            
            let dayOpenWorth: Double = (self.currentUser?.dayOpenWorth())!
            let dayChange: Double = currentWorth - dayOpenWorth
            self.dayChangeLabel.text = currencyFormat(value: dayChange)
            self.dayPercentLabel.text = percentFormat(value: getPercentage(value: dayOpenWorth, change: dayChange))
            if dayChange < 0.0{
                self.dayChangeIcon.image = decreaseIcon
            }else{
                self.dayChangeIcon.image = increaseIcon
            }
            
            let initialWorth: Double = 100000.0
            let overallChange: Double = currentWorth - initialWorth
            let overallChangePercent: Double = getPercentage(value: initialWorth, change: overallChange)
            self.overallChangeLabel.text = currencyFormat(value: overallChange)
            self.overallPercentLabel.text = percentFormat(value: overallChangePercent)
            if overallChange < 0.0{
                self.overallChangeIcon.image = decreaseIcon
            }else{
                self.overallChangeIcon.image = increaseIcon
            }
            
            self.stocksTableView.reloadData()
            
        }
        
        //self.balanceLabel.text = currencyFormat(value: (self.currentUser?.balance)!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewDidLoad()
        stocksTableView.reloadData()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (currentUser?.stocks.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let pCell = stocksTableView.dequeueReusableCell(withIdentifier: "portfolioCell", for: indexPath) as? PortfolioCell {
            let stockSymbol: String = self.sortedKeys[indexPath.row]
            pCell.symbolLabel.text = stockSymbol
            let numShares = self.currentUser?.stocks[stockSymbol]!["shares"] as! Int
            pCell.sharesLabel.text = String(numShares) + " Shares"
            
            if !(self.currentUser?.stockData.isEmpty)! {
                let stockData = self.currentUser?.stockData[stockSymbol] as! [String:Any]
                let value = stockData["latestPrice"] as! Double
                pCell.valueLabel.text = currencyFormat(value: value)
            }
            
            return pCell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedStock = self.sortedKeys[indexPath.row]
        performSegue(withIdentifier: "showStock", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? StockViewController {
            dest.symbol = self.selectedStock
            dest.currentUser = self.currentUser
        }
    }

}
