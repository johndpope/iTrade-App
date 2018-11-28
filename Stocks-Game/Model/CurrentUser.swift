//
//  CurrentUser.swift
//  Stocks-Game
//
//  Created by Fatih Ak on 11/14/18.
//  Copyright © 2018 Fatih Ak. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import Alamofire


class CurrentUser {
    
    var balance: Double! = 0.0
    var stocks: [String:[String:Any]]! = ["":[:]]
    var history: [String:[String:Any]]! = ["":[:]]
    var name: String = ""
    var stockData = Dictionary<String, Any >()
    let id: String!
    
    let currentUser = Auth.auth().currentUser
    let dbRef = Database.database().reference()
    
    init() {
        self.id = (Auth.auth().currentUser?.uid as String?)!
        self.dbRef.child("Users").child(self.id).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! [String:Any]?
            self.balance = value!["balance"] as! Double
            self.stocks = value!["stocks"] as! [String:[String:Any]]?
            self.history = value!["history"] as! [String:[String:Any]]?
            self.name = value!["name"] as! String
//            }else{
//                self.name = self.currentUser?.displayName as! String
//                self.dbRef.child("Users/\(String(describing: Auth.auth().currentUser?.uid))/name/").setValue(self.name)
//            }
            
            if !self.history.keys.contains(getDate()){
                let todayData: [String : Any] = ["balance": self.balance, "stocks": self.stocks ]
                self.history[getDate()] = todayData
                self.dbRef.child("Users/\(self.id!)/history/").setValue(self.history)
            }
            
            if self.stocks == nil{
                self.stocks = [:]
            }
        }){ (error) in
            print(error.localizedDescription)
        }
        
    }
    
    init(id: String) {
        self.id = id
        self.dbRef.child("Users").child(self.id).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! [String:Any]?
            self.balance = value!["balance"] as! Double
            self.stocks = [:]
            if value!["stocks"] != nil{
                self.stocks = value!["stocks"] as! [String:[String:Any]]?
            }
            self.history = value!["history"] as! [String:[String:Any]]
            self.name = value!["name"] as! String
            
            //            }else{
            //                self.name = self.currentUser?.displayName as! String
            //                self.dbRef.child("Users/\(String(describing: Auth.auth().currentUser?.uid))/name/").setValue(self.name)
            //            }
            if !self.history.keys.contains(getDate()){
                var todayData: [String : Any] = ["balance": self.balance, "stocks": self.stocks ]
                if self.stocks == nil{
                    todayData = ["balance": self.balance]
                }
                self.history[getDate()] = todayData
                self.dbRef.child("Users").child(self.id).child("history").child(getDate()).setValue(todayData)
            }
        }){ (error) in
            print(error.localizedDescription)
        }
        
    }
    
    func getUserData(withCompletion completion: @escaping (Bool) -> Void) {
        
        self.dbRef.child("Users").child(self.id).observeSingleEvent(of: .value, with: { (snapshot) in
//                let curName = (Auth.auth().currentUser?.displayName as String?)!
//                if self.name != (Auth.auth().currentUser?.displayName as String?)!{
//                    var hi = "hello"
//                
//                }
                
                let value = snapshot.value as! [String:Any]?
                self.balance = value!["balance"] as! Double
                self.stocks = value!["stocks"] as! [String:[String:Any]]?
                self.history = value!["history"] as! [String:[String:Any]]?
                self.name = value!["name"] as! String
            
                if self.name != (Auth.auth().currentUser?.displayName as String?)!{
                    let hi = true
                }
            
                if !self.history.keys.contains(getDate()){
                    var todayData: [String : Any] = ["balance": self.balance, "stocks": self.stocks ]
                    if self.stocks == nil{
                        todayData = ["balance": self.balance]
                    }
                    self.history[getDate()] = todayData
                    self.dbRef.child("Users/\(self.id!)/history/").setValue(self.history)
                }
                if self.stocks == nil{
                    self.stocks = [:]
                }
                completion(true)
        })
        
    }
    
    func buyStock(symbol: String, shares: Int, price: Double ){
        var newVal = 0
        if self.stocks.keys.contains(symbol){
            let currentShares = self.stocks[symbol]!["shares"] as! Int
            newVal = currentShares + shares
            self.stocks[symbol]!["shares"] = newVal
        }else{
            newVal = shares
            self.stocks[symbol] = [:]
            self.stocks[symbol]!["shares"] = shares
        }
        self.dbRef.child("Users/\(self.id!)/stocks/\(symbol)/shares").setValue(newVal)
        
        self.balance = self.balance - (Double(shares)*price) - 10
        self.dbRef.child("Users/\(self.id!)/balance").setValue(self.balance)
        self.getStockData{_ in }
    }
    
    func sellStock(symbol: String, shares: Int, price: Double){
        var newVal = 0
        let currentShares = self.stocks[symbol]!["shares"] as! Int
        newVal = currentShares - shares
        self.stocks[symbol]!["shares"] = newVal
        
        self.dbRef.child("Users/\(self.id!)/stocks/\(symbol)/shares").setValue(newVal)
        
        self.balance = self.balance + (Double(shares)*price) - 10
        self.dbRef.child("Users/\(self.id!)/balance").setValue(self.balance)
        self.getStockData{_ in }
    }
    
    func owns(symbol: String) -> Bool{
        return self.stocks.keys.contains(symbol)
    }
    
    func getOrderedList() -> [String]{
        var result: [String] = []
        for (symbol, _) in self.stocks {
            result.append(symbol)
        }
        return result
    }
    
    func getStockData(withCompletion completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        
        
        for symbol in self.stocks.keys{
            group.enter()
            let todoEndpoint: String = "https://api.iextrading.com/1.0/stock/" + symbol + "/quote"
            Alamofire.request(todoEndpoint)
                .responseJSON { response in
                    guard let json = response.result.value as? [String: Any] else {
                        return
                    }
                    self.stockData[symbol] = json
                    group.leave()
                    
            }
        }
        group.notify(queue: .main) {
            completion(true)
        }
    }
    
    func currentWorth() -> Double{
        var worth = self.balance as! Double
        for symbol in self.stocks.keys{
            let stockData = self.stockData[symbol] as! [String:Any]
            let value = stockData["latestPrice"] as! Double
            let shares = self.stocks[symbol]!["shares"] as! Int
            worth = worth + Double(value * Double(shares))
        }
        return worth
    }
    
    func dayOpenWorth() -> Double{
//        var data: [String:Any] = [:]
//        if self.history[getDate()] != nil{
        let data = self.history[getDate()] as! [String: Any]
//        }else{
//            return 0.0
//        }
        var worth = data["balance"] as! Double
        
        if data.keys.contains("stocks"){
            let stocks = data["stocks"] as! [String:[String:Any]]
            for symbol in stocks.keys{
                let stockData = self.stockData[symbol] as! [String:Any]
                let value = stockData["previousClose"] as! Double
                let shares = stocks[symbol]!["shares"] as! Int
                worth = worth + Double(value * Double(shares))
            }
        }
        return worth
    }
}
