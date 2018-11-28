//
//  Stock.swift
//  Stocks-Game
//
//  Created by Fatih Ak on 10/22/18.
//  Copyright © 2018 Fatih Ak. All rights reserved.
//

import Foundation
import Alamofire

@objc class Stock: NSObject {
    
    var name: String!
    var symbol: String!
    var price: Double!
    var change: Double!
    
    override init(){
        self.symbol = ""
        self.name = ""
        self.price = 0.0
        self.change = 0.0
    }
    
    init(dict: [String:Any]) {
        self.symbol = dict["symbol"] as? String ?? ""
        self.name = dict["companyName"] as? String ?? ""
        self.price = dict["latestPrice"] as? Double ?? 0.0
        self.change = dict["change"] as? Double ?? 0.0
        
        /*
        super.init()
        self.getStockInfo(param: symbol) {response in
            self.name = response["companyName"] as? String ?? ""
            self.price = response["latestPrice"] as? Double ?? 0.0
            self.change = response["change"] as? Double ?? 0.0
        }
        */
    }
    
    func getStockInfo(param: String, completion: @escaping ([String: Any]) -> Void) {
        var result: [String: Any] = [:]
        let todoEndpoint: String = "https://api.iextrading.com/1.0/stock/" + param + "/quote"
        Alamofire.request(todoEndpoint)
            .responseJSON { response in
                guard let json = response.result.value as? [String: Any] else {
                    return
                }
                result = json
        }
        completion(result)
    }
    
    
    func updateStock(){
        let todoEndpoint: String = "https://api.iextrading.com/1.0/stock/" + symbol + "/quote"
        Alamofire.request(todoEndpoint)
            .responseJSON { response in
                guard let json = response.result.value as? [String: Any] else {
                    return
                }
                let changeVal = json["change"] as? Double ?? 0.0
                
                self.name = json["companyName"] as? String ?? ""
                self.price = json["latestPrice"] as? Double ?? 0.0
                self.change = changeVal
        }
    }
    
}
