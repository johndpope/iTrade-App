//
//  StockTableViewController.swift
//  Stocks-Game
//
//  Created by Fatih Ak on 10/22/18.
//  Copyright © 2018 Fatih Ak. All rights reserved.
//

import UIKit
import Alamofire

class StockTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{

    @IBOutlet var navigationbar: UINavigationItem!
    
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var mySearchBar: UISearchBar!
    @IBOutlet var myTableView: UITableView!
    
    @IBOutlet var topGainTable: UITableView!
    @IBOutlet var topLossTable: UITableView!
    
    @IBOutlet var gainImage: UIImageView!
    @IBOutlet var lossImage: UIImageView!
    var currentUser: CurrentUser? = nil
    
    var stockTest: Stock!
    let todoEndpoint: String = "https://api.iextrading.com/1.0/ref-data/symbols"
    var stockList: [String] = []
    var filteredStockList: [String] = []
    var searching = false
    var stockObjects: [String: Stock] = [:]
    var selectedStock: String = ""
    
    var orderedGainStocks: [String] = []
    var topGainStocks: [String:[String:Any]] = [:]
    
    var orderedLoseStocks: [String] = []
    var topLoseStocks: [String:[String:Any]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStockArray()

        self.myTableView.delegate = self
        self.myTableView.dataSource = self
        
        self.mySearchBar.delegate = self
        
        self.topGainTable.delegate = self
        self.topGainTable.dataSource = self
        
        self.topLossTable.delegate = self
        self.topLossTable.dataSource = self
        
        self.navigationbar.title = "Trading Center"
        self.navigationbar.leftBarButtonItem = nil
        // self.navigationbar.titleView = self.mySearchBar
        self.myTableView.alpha = 0.0
        self.mySearchBar.alpha = 0.0
        
        let gainersEndpoint: String = "https://api.iextrading.com/1.0/stock/market/list/gainers"
        Alamofire.request(gainersEndpoint)
            .responseJSON { response in
                guard let json = response.result.value as? [[String: Any]] else {
                    return
                }
                for stock in json{
                    let stockSymbol = stock["symbol"] as! String
                    self.topGainStocks[stockSymbol] = stock
                }
                
                self.orderedGainStocks = self.topGainStocks.keys.sorted{(self.topGainStocks[$0]!["changePercent"] as! Double) > (self.topGainStocks[$1]!["changePercent"] as! Double)}
                self.topGainTable.reloadData()
        }
        
        let losersEndpoint: String = "https://api.iextrading.com/1.0/stock/market/list/losers"
        Alamofire.request(losersEndpoint)
            .responseJSON { response in
                guard let json = response.result.value as? [[String: Any]] else {
                    return
                }
                for stock in json{
                    let stockSymbol = stock["symbol"] as! String
                    self.topLoseStocks[stockSymbol] = stock
                }
                
                self.orderedLoseStocks = self.topLoseStocks.keys.sorted{(self.topLoseStocks[$0]!["changePercent"] as! Double) < (self.topLoseStocks[$1]!["changePercent"] as! Double)}
                self.topLossTable.reloadData()
        }
        
        let increaseIcon: UIImage = UIImage(named: "increase.png")!
        let decreaseIcon: UIImage = UIImage(named: "decrease.png")!
        self.gainImage.image = increaseIcon
        self.lossImage.image = decreaseIcon
        
        self.topGainTable.layer.cornerRadius = 14
        self.topGainTable.layer.masksToBounds = true
        self.topGainTable.layer.borderColor = UIColor( red: 250/255, green: 250/255, blue:250/255, alpha: 1.0 ).cgColor
        self.topGainTable.layer.borderWidth = 2.0
        
        self.topLossTable.layer.cornerRadius = 14
        self.topLossTable.layer.masksToBounds = true
        self.topLossTable.layer.borderColor = UIColor( red: 250/255, green: 250/255, blue:250/255, alpha: 1.0 ).cgColor
        self.topLossTable.layer.borderWidth = 2.0
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        self.topLossTable.alpha = 0.0
        self.topGainTable.alpha = 0.0
        self.myTableView.alpha = 1.0
        self.mySearchBar.alpha = 1.0
        self.navigationbar.titleView = self.mySearchBar
        self.navigationbar.leftBarButtonItem = self.cancelButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationbar.leftBarButtonItem = nil
        self.navigationbar.titleView = nil
        self.myTableView.alpha = 0.0
        self.mySearchBar.alpha = 0.0
        self.topLossTable.alpha = 1.0
        self.topGainTable.alpha = 1.0
        self.topLossTable.reloadData()
        self.topGainTable.reloadData()
        self.mySearchBar.text = ""
        self.searching = false
        self.filteredStockList = []
        
        DispatchQueue.main.async{
            self.myTableView.reloadData()
        }
    }

 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancelSearchButtonClicked(_ sender: Any) {
        self.mySearchBar.alpha = 0.0
        self.myTableView.alpha = 0.0
        self.topLossTable.alpha = 1.0
        self.topGainTable.alpha = 1.0
        self.navigationbar.titleView = nil
        self.navigationbar.leftBarButtonItem = nil
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredStockList = self.stockList.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
        self.searching = true
        if searchText == ""{
            self.searching = false
        }
        myTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.myTableView{
            if self.searching{
                return self.filteredStockList.count
            }else{
                return 0
            }
        }else if tableView == self.topGainTable{
            return self.orderedGainStocks.count
        }else if tableView == self.topLossTable{
            return self.orderedLoseStocks.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.myTableView{
            return 55
        }else{
            return 44
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.myTableView{
            if searching{
                self.selectedStock = self.filteredStockList[indexPath.row]
            }
        }else if tableView == self.topGainTable{
            self.selectedStock = self.orderedGainStocks[indexPath.row]
        }else{
            self.selectedStock = self.orderedLoseStocks[indexPath.row]
        }
        performSegue(withIdentifier: "showStock", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.myTableView{
            if let stockCell = myTableView.dequeueReusableCell(withIdentifier: "stockCell", for: indexPath) as? stockTableViewCell {
                var stockSymbol = ""
                if searching{
                    stockSymbol = self.filteredStockList[indexPath.row]
                }else{
                    stockSymbol = self.stockList[indexPath.row]
                }
                stockCell.stockSymbolLabel.text = stockSymbol
            
                let todoEndpoint: String = "https://api.iextrading.com/1.0/stock/" + stockSymbol + "/quote"
                Alamofire.request(todoEndpoint).responseJSON { response in
                    guard let json = response.result.value as? [String: Any] else {
                        return
                    }
                    guard let companyName = json["companyName"] as? String else{
                        self.stockList.remove(at: indexPath.row)
                        return
                    }
                    if companyName == "" {
                        self.stockList.remove(at: indexPath.row)
                        return
                    }
                    guard let ch = json["change"] as? Double else{
                        self.stockList.remove(at: indexPath.row)
                        return
                    }
                    stockCell.stockNameLabel.text = companyName
                    stockCell.stockPercentLabel.text = percentFormat(value: ch)
                    if ch < 0 {
                        stockCell.stockPercentLabel.textColor = UIColor( red: CGFloat(254/255.0), green: CGFloat(23/255.0), blue: CGFloat(7/255.0), alpha: CGFloat(1.0) )
                    }else{
                        stockCell.stockPercentLabel.textColor = UIColor( red: CGFloat(50/255.0), green: CGFloat(255/255.0), blue: CGFloat(50/255.0), alpha: CGFloat(1.0) )
                    }
                }
                return stockCell
            }
        }else if tableView == self.topGainTable{
            if let stockCell = topGainTable.dequeueReusableCell(withIdentifier: "topGainCell", for: indexPath) as? stockExploreCell {
                let symbol = self.orderedGainStocks[indexPath.row]
                stockCell.stockSymbolLabel.text = symbol
                
                let stockData = self.topGainStocks[symbol] as! [String:Any]
                stockCell.priceLabel.text = currencyFormat(value: stockData["latestPrice"] as! Double)
                stockCell.changeLabel.text = percentFormat(value: (stockData["changePercent"] as! Double)*100.0)
                stockCell.changeLabel.textColor = UIColor( red: CGFloat(50/255.0), green: CGFloat(255/255.0), blue: CGFloat(50/255.0), alpha: CGFloat(1.0) )
                
                return stockCell
            }
        }else if tableView == self.topLossTable{
            if let stockCell = topLossTable.dequeueReusableCell(withIdentifier: "topLossCell", for: indexPath) as? stockExploreCell {
                let symbol = self.orderedLoseStocks[indexPath.row]
                stockCell.stockSymbolLabel.text = symbol
                
                let stockData = self.topLoseStocks[symbol] as! [String:Any]
                stockCell.priceLabel.text = currencyFormat(value: stockData["latestPrice"] as! Double)
                stockCell.changeLabel.text = percentFormat(value: (stockData["changePercent"] as! Double)*100.0)
                stockCell.changeLabel.textColor = UIColor( red: CGFloat(254/255.0), green: CGFloat(23/255.0), blue: CGFloat(7/255.0), alpha: CGFloat(1.0) )
                
                return stockCell
            }
        }
        return UITableViewCell()
    }
    
    
    func getStockArray(){
        Alamofire.request(self.todoEndpoint)
            .responseJSON { response in
                guard let json = response.result.value as? [[String:Any]] else {
                    return
                }
                for dict in json{
                    let symbol = dict["symbol"] as? String ?? ""
                    
//                    self.getStockData(symbol: symbol)
                    self.stockList.append(symbol)
                }
                DispatchQueue.main.async{
                    self.myTableView.reloadData()
                }
        }
    }
    
    func getStockData(symbol: String) {
        let todoEndpoint: String = "https://api.iextrading.com/1.0/stock/" + symbol + "/quote"
        var stockObject: Stock = Stock()
        
        Alamofire.request(todoEndpoint)
            .responseJSON { response in
                guard let json = response.result.value as? [String: Any] else {
                    return
                }
                stockObject =  Stock(dict: json)
                self.stockObjects[symbol] = stockObject
                
                DispatchQueue.main.async{
                    self.myTableView.reloadData()
                }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? StockViewController {
            dest.symbol = self.selectedStock
            dest.currentUser = self.currentUser
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
