//
//  StockViewController.swift
//  Stocks-Game
//
//  Created by Fatih Ak on 10/21/18.
//  Copyright © 2018 Fatih Ak. All rights reserved.
//

import UIKit
import Alamofire

class StockViewController: UIViewController {

    @IBOutlet var NewsView: UIView!
    @IBOutlet var DataView: UIView!
    var DataVC: DataViewController?
    var NewsVC: NewsViewController?
    var selectedArticle: String = ""
    
    var currentUser: CurrentUser? = nil
    
    var tabChosen: Int = 0
    var symbol: String = ""
    var companyName: String = ""
    var stockPrice: Double = 0.0
    var close: Double = 0.0
    var data: [String: Any] = [:]
    var news: [[String:Any]] = [[:]]
    
    @IBOutlet var stockTab: UISegmentedControl!
    @IBOutlet var dataStack: UIStackView!
    
    @IBOutlet var CompanyNameLabel: UILabel!
    @IBOutlet var SymbolLabel: UILabel!
    @IBOutlet var PriceLabel: UILabel!
    @IBOutlet var changeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.NewsView.alpha = 0
        self.DataView.alpha = 1
        
        let todoEndpoint: String = "https://api.iextrading.com/1.0/stock/" + self.symbol + "/quote"
        Alamofire.request(todoEndpoint)
            .responseJSON { response in
                guard let json = response.result.value as? [String: Any] else {
                    self.CompanyNameLabel.text = "didn't get todo object as JSON from API"
                    return
                }
                self.data["CompanyName"] = json["companyName"] as? String ?? ""
                self.data["LatestPrice"] = json["latestPrice"] as? Double ?? 0.0
                self.data["change"] = json["change"] as? Double ?? 0.0
                self.data["close"] = json["close"] as? Double ?? 0.0
                self.data["open"] = json["open"] as? Double ?? 0.0
                self.data["low"] = json["low"] as? Double ?? 0.0
                self.data["high"] = json["high"] as? Double ?? 0.0
                self.data["latestVolume"] = json["latestVolume"] as? Double ?? 0.0
                self.data["avgTotalVolume"] = json["avgTotalVolume"] as? Double ?? 0.0
        
        
        
                self.SymbolLabel.text = self.symbol
                self.CompanyNameLabel.text = self.data["CompanyName"] as? String
                self.companyName = (self.data["CompanyName"] as? String)!
                self.PriceLabel.text = String(self.data["LatestPrice"] as! Double)
                self.stockPrice = self.data["LatestPrice"] as! Double
                let change = self.data["change"] as! Double
                if change < 0.0 {
                    self.changeLabel.text = String(change) + "%"
                    self.changeLabel.textColor = UIColor.red
                }else if change > 0.0{
                    self.changeLabel.text = "+" + String(change) + "%"
                    self.changeLabel.textColor = UIColor.green
                }
        }
        
        let statsEndpoint: String = "https://api.iextrading.com/1.0/stock/" + self.symbol + "/stats"
        Alamofire.request(statsEndpoint)
            .responseJSON { response in
                guard let json = response.result.value as? [String: Any] else {
                    self.CompanyNameLabel.text = "didn't get todo object as JSON from API"
                    return
                }

                self.data["week52low"] = json["week52low"] as? Double ?? 0.0
                self.data["week52high"] = json["week52high"] as? Double ?? 0.0
                self.data["marketcap"] = json["marketcap"] as? Double ?? 0.0
                self.data["peRatioHigh"] = json["peRatioHigh"] as? Double ?? 0.0
                self.data["beta"] = json["beta"] as? Double ?? 0.0
                self.data["dividendYield"] = json["dividendYield"] as? Double ?? 0.0
                self.data["dividendRate"] = json["dividendRate"] as? Double ?? 0.0
            }
        
        let newsEndpoint: String = "https://newsapi.org/v2/everything?q=+" + self.symbol + "+stock&apiKey=" + "1392b13880be4dcba235362e54dfff27&language=en"
        Alamofire.request(newsEndpoint)
            .responseJSON { response in
                guard let json = response.result.value as? [String: Any] else {
                    return
                }
                self.news = json["articles"] as? [[String:Any]] ?? [[:]]
                self.NewsVC?.news = self.news
                self.NewsVC?.newsTableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func tabChanged(_ sender: Any) {
        switch(self.stockTab.selectedSegmentIndex){
        case 0:
            self.NewsView.alpha = 0
            self.DataView.alpha = 1
        case 1:
            self.NewsView.alpha = 1
            self.DataView.alpha = 0
        default:
            self.NewsView.alpha = 0
            self.DataView.alpha = 1
        }
    }
    
    @IBAction func unwindToStockView(segue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showData"{
            self.DataVC = segue.destination as? DataViewController
        }
        if segue.identifier == "showNews"{
            self.NewsVC = segue.destination as? NewsViewController
            self.NewsVC?.parentView = self
        }
        if segue.identifier == "showArticle"{
            if let dest = segue.destination as? ArticleViewController {
                dest.articleURL = self.selectedArticle
            }
        }
        if segue.identifier == "buyStock" || segue.identifier == "sellStock"{
            if let dest = segue.destination as? BuyViewController {
                dest.currentUser = self.currentUser
                dest.stockPrice = self.stockPrice
                dest.stockName = self.companyName
                dest.stockSymbol = self.symbol
                
                if segue.identifier == "buyStock"{
                    dest.type = 0
                }else{
                    dest.type = 1
                }
            }
        }
    }


}
