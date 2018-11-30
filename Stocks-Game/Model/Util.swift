//
//  Util.swift
//  Stocks-Game
//
//  Created by Fatih Ak on 11/15/18.
//  Copyright © 2018 Fatih Ak. All rights reserved.
//

import Foundation
import Alamofire


func currencyFormat(value: Double) -> String {
    let currencyFormatter = NumberFormatter()
    currencyFormatter.usesGroupingSeparator = true
    currencyFormatter.numberStyle = .currency
    currencyFormatter.locale = Locale.current
    return currencyFormatter.string(from: value as NSNumber)!
}

func percentFormat(value: Double) -> String{
    let rounded: String = String(format: "%.2f", value)
    return rounded + "%"
}

func getDate() -> String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "ddMMyyyy"
    let result = formatter.string(from: date)
    return result
}

func dateFromString(dateStr: String) -> NSDate {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "ddMMyyyy"
    
    return dateFormatter.date(from: dateStr)! as NSDate
}

func getPercentage(value: Double, change: Double) -> Double {
    let percentage: Double = (change/value)*100.0
    return percentage
}

extension Double {
    func truncate(places: Int) -> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}

func formatNumber(_ n: Double) -> String {
    
    let num = abs(n)
    let sign = (n < 0) ? "-" : ""
    
    switch num {
        
    case 1_000_000_000...:
        var formatted = num / 1_000_000_000
        formatted = formatted.truncate(places: 1)
        return "\(sign)\(formatted)B"
        
    case 1_000_000...:
        var formatted = num / 1_000_000
        formatted = formatted.truncate(places: 1)
        return "\(sign)\(formatted)M"
        
    case 1_000...:
        var formatted = num / 1_000
        formatted = formatted.truncate(places: 1)
        return "\(sign)\(formatted)K"
        
    case 0...:
        return "\(n)"
        
    default:
        return "\(sign)\(n)"
        
    }
    
}



