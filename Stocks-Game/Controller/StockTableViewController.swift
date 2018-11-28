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
    
    var currentUser: CurrentUser? = nil
    
    var stockTest: Stock!
    
    let todoEndpoint: String = "https://api.iextrading.com/1.0/ref-data/symbols"
    var stockList: [String] = []
    var filteredStockList: [String] = []
    var searching = false
    var stockObjects: [String: Stock] = [:]
    var selectedStock: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStockArray()

        self.myTableView.delegate = self
        self.myTableView.dataSource = self
        self.mySearchBar.delegate = self
        
        self.navigationbar.title = "Trading Center"
        self.navigationbar.leftBarButtonItem = nil
        // self.navigationbar.titleView = self.mySearchBar
        self.myTableView.alpha = 0.0
        self.mySearchBar.alpha = 0.0
        
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        self.myTableView.alpha = 1.0
        self.mySearchBar.alpha = 1.0
        self.navigationbar.titleView = self.mySearchBar
        self.navigationbar.leftBarButtonItem = self.cancelButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.myTableView.alpha = 0.0
        self.mySearchBar.alpha = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
        if self.searching{
            return self.filteredStockList.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searching{
            self.selectedStock = self.filteredStockList[indexPath.row]
        }
        performSegue(withIdentifier: "showStock", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let stockCell = myTableView.dequeueReusableCell(withIdentifier: "stockCell", for: indexPath) as? stockTableViewCell {
            
            var stockSymbol = ""
            if searching{
                stockSymbol = self.filteredStockList[indexPath.row]
            }else{
                stockSymbol = self.stockList[indexPath.row]
            }
            stockCell.stockSymbolLabel.text = stockSymbol
            
            let todoEndpoint: String = "https://api.iextrading.com/1.0/stock/" + stockSymbol + "/quote"
            Alamofire.request(todoEndpoint)
                .responseJSON { response in
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
                    
                    stockCell.stockPercentLabel.text = String(ch) + "%"
                    if ch < 0 {
                        stockCell.stockPercentLabel.textColor = UIColor( red: CGFloat(23/255.0), green: CGFloat(190/255.0), blue: CGFloat(23/255.0), alpha: CGFloat(1.0) )
                        stockCell.stockPercentLabel.text = String(ch) + "%"
                    }else{
                        stockCell.stockPercentLabel.textColor = UIColor( red: CGFloat(197/255.0), green: CGFloat(0/255.0), blue: CGFloat(50/255.0), alpha: CGFloat(1.0) )
                        stockCell.stockPercentLabel.text = "+" + String(ch) + "%"
                    }
                    
            }
        return stockCell
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
