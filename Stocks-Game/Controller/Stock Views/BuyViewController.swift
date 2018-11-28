//
//  BuyViewController.swift
//  Stocks-Game
//
//  Created by Fatih Ak on 11/13/18.
//  Copyright © 2018 Fatih Ak. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class BuyViewController: UIViewController {

    @IBOutlet var companyNameLabel: UILabel!
    @IBOutlet var slidingSharesLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var sharesLabel: UILabel!
    @IBOutlet var totalLabel: UILabel!
    @IBOutlet var sliderObject: UISlider!
    
    let dbRef = Database.database().reference()
    var type = 0
    var stockName = ""
    var stockSymbol = ""
    var stockPrice = 0.0
    var balance = 0.0
    
    var shares = 0
    
    var currentUser: CurrentUser? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.companyNameLabel.text = self.stockName
        self.sliderObject.maximumValue = 0
        if self.type == 0{
            self.title = "Buy " + self.stockSymbol
            self.balance = (self.currentUser?.balance)!
            self.sliderObject.maximumValue = Float(Int(floor((self.balance-10)/self.stockPrice)))
            
        }else{
            self.title = "Sell " + self.stockSymbol
            if (self.currentUser?.owns(symbol: self.stockSymbol))!{
                self.shares = self.currentUser?.stocks[self.stockSymbol]!["shares"] as! Int
                self.sliderObject.maximumValue = Float(self.shares)
            }
        }
        
        self.priceLabel.text = currencyFormat(value: self.stockPrice)
        self.totalLabel.text = currencyFormat(value: 0.0)
        self.slidingSharesLabel.text = "0 Shares"
        self.sharesLabel.text = "0"
        
        self.sliderObject.value = 0
        self.sliderObject.minimumValue = 0
        
        
//        self.dbRef.child("Users").child("\(String(describing: Auth.auth().currentUser?.uid))").child("balance").observeSingleEvent(of: .value, with: { (snapshot) in
//            let value = snapshot.value as! Double
//            self.balance = value
//            self.sliderObject.maximumValue = Float(Int(floor((value-10)/self.stockPrice)))
//        }){ (error) in
//            print(error.localizedDescription)
//        }

        // Do any additional setup after loading the view.
    }
    
    

    @IBAction func sliderValueChanged(_ sender: Any) {
        let roundedVal = Int(sliderObject.value)
        sliderObject.value = Float(roundedVal)
        self.slidingSharesLabel.text = String(roundedVal) + " Shares"
        self.sharesLabel.text = String(roundedVal)
        self.totalLabel.text =  currencyFormat(value:(Double(roundedVal) * self.stockPrice)+10)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func orderButtonPressed(_ sender: Any) {
        if self.type == 0 && self.balance>0{
            self.currentUser?.buyStock(symbol: self.stockSymbol, shares: Int(self.sliderObject.value), price: self.stockPrice)
        }else if self.type == 1 && self.shares > 0 {
            self.currentUser?.sellStock(symbol: self.stockSymbol, shares: Int(self.sliderObject.value), price: self.stockPrice)
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
