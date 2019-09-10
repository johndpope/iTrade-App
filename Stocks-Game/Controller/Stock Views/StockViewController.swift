//
//  StockViewController.swift
//  Stocks-Game
//
//  Created by Fatih Ak on 10/21/18.
//  Copyright © 2018 Fatih Ak. All rights reserved.
//

import UIKit
import Alamofire

class StockViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet var dataStackView: UIStackView!
    @IBOutlet var newsTableView: UITableView!
    
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
    
    @IBOutlet var prevCloseLabel: UILabel!
    @IBOutlet var openLabel: UILabel!
    @IBOutlet var dayRangeLabel: UILabel!
    @IBOutlet var wkRangeLabel: UILabel!
    @IBOutlet var marketCapLabel: UILabel!
    @IBOutlet var volumeLabel: UILabel!
    @IBOutlet var averageVolumeLabel: UILabel!
    @IBOutlet var peRatioLabel: UILabel!
    @IBOutlet var betaLabel: UILabel!
    @IBOutlet var yieldLabel: UILabel!
    @IBOutlet var dividendLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.newsTableView.delegate = self
        self.newsTableView.dataSource = self
        
        self.newsTableView.alpha = 0
        self.dataStackView.alpha = 1
        
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
        
                self.prevCloseLabel.text = currencyFormat(value: self.data["close"] as! Double)
                self.openLabel.text = currencyFormat(value: self.data["open"] as! Double)
                self.dayRangeLabel.text = currencyFormat(value: self.data["low"] as! Double) + " - " + currencyFormat(value: self.data["high"] as! Double)
                self.averageVolumeLabel.text = formatNumber(self.data["avgTotalVolume"] as! Double)
                
                
                self.SymbolLabel.text = self.symbol
                self.CompanyNameLabel.text = self.data["CompanyName"] as? String
                self.companyName = (self.data["CompanyName"] as? String)!
                self.PriceLabel.text = String(self.data["LatestPrice"] as! Double)
                self.stockPrice = self.data["LatestPrice"] as! Double
                let change = self.data["change"] as! Double
                if change < 0.0 {
                    self.changeLabel.text = percentFormat(value: change)
                    self.changeLabel.textColor = UIColor( red: CGFloat(254/255.0), green: CGFloat(23/255.0), blue: CGFloat(7/255.0), alpha: CGFloat(1.0) )
                }else if change > 0.0{
                    self.changeLabel.text = percentFormat(value: change)
                    self.changeLabel.textColor = UIColor( red: CGFloat(50/255.0), green: CGFloat(250/255.0), blue: CGFloat(50/255.0), alpha: CGFloat(1.0) )
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
                self.data["eps"] = json["latestEPS"] as? Double ?? 0.0
                self.data["beta"] = json["beta"] as? Double ?? 0.0
                self.data["dividendYield"] = json["dividendYield"] as? Double ?? 0.0
                self.data["dividendRate"] = json["dividendRate"] as? Double ?? 0.0
                
                self.wkRangeLabel.text = currencyFormat(value: self.data["week52low"] as! Double) + " - " + currencyFormat(value: self.data["week52high"] as! Double)
                self.betaLabel.text = String(format: "%.3f",self.data["beta"] as! Double)
                self.peRatioLabel.text = String(self.data["peRatioHigh"] as! Double)
                self.marketCapLabel.text = "$" + formatNumber(self.data["marketcap"] as! Double)
                self.volumeLabel.text = currencyFormat(value: self.data["eps"] as! Double)
                self.yieldLabel.text = percentFormat(value: self.data["dividendYield"] as! Double)
                self.dividendLabel.text = currencyFormat(value: self.data["dividendRate"] as! Double)
            }
        let apiKey: String = "1392b13880be4dcba235362e54dfff27"
        let newsEndpoint: String = "https://newsapi.org/v2/everything?q=+" + self.symbol + "+stock&apiKey=" + apiKey + "&language=en"
        Alamofire.request(newsEndpoint)
            .responseJSON { response in
                guard let json = response.result.value as? [String: Any] else {
                    return
                }
                self.news = json["articles"] as? [[String:Any]] ?? [[:]]
                self.newsTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.news.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let newsData = self.news[indexPath.row]

        if let _ = newsData["urlToImage"] as? String{
            return 190
        }else{
            return 74
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedArticle = self.news[indexPath.row]["url"] as! String
        performSegue(withIdentifier: "showArticle", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newsData = self.news[indexPath.row]
        if let _ = newsData["urlToImage"] as? String{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as? NewsCell{
                cell.headLineLabel.text = newsData["title"] as? String
            
                let imageUrl = newsData["urlToImage"] as? String ?? ""
                let urlImg = NSURL(string: imageUrl )
                let data = NSData.init(contentsOf: urlImg! as URL)
                if data != nil {
                    cell.newsImage.image = UIImage(data:data! as Data)
                }
                return cell
            }
        }else{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell2", for: indexPath) as? NewsCell{
                cell.headLineLabel.text = newsData["title"] as? String

                return cell
            }
        }
        return UITableViewCell()
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
            self.newsTableView.alpha = 0
            self.dataStackView.alpha = 1
        case 1:
            self.newsTableView.alpha = 1
            self.dataStackView.alpha = 0
        default:
            self.newsTableView.alpha = 0
            self.dataStackView.alpha = 1
        }
    }
    
    @IBAction func unwindToStockView(segue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

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
