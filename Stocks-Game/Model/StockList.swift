//
//  StockList.swift
//  
//
//  Created by Fatih Ak on 10/22/18.
//

import Foundation
import Alamofire

class StockList{
    
    static func getStockArray() -> [String] {
        var StockArray: [String] = []
        
        let todoEndpoint: String = "https://api.iextrading.com/1.0/ref-data/symbols"
        Alamofire.request(todoEndpoint)
            .responseJSON { response in
                guard let json = response.result.value as? [[String:Any]] else {
                    return
                }
                for dict in json{
                    let symbol = dict["symbol"] as? String ?? ""
                    StockArray.append(symbol)
                }
                
        }
        return StockArray
    }
    
}
