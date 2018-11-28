//
//  NewsViewController.swift
//  Stocks-Game
//
//  Created by Fatih Ak on 11/4/18.
//  Copyright © 2018 Fatih Ak. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var news: [[String: Any]] = [[:]]
    
    var parentView: StockViewController = StockViewController()
    
    @IBOutlet var newsTableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.parentView.selectedArticle = news[indexPath.row]["url"] as! String
        performSegue(withIdentifier: "unwindToStockView", sender: self)
        self.parentView.performSegue(withIdentifier: "showArticle", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as? NewsCell{
            let newsData = news[indexPath.row]
            cell.headLineLabel.text = newsData["title"] as? String
            
            let imageUrl = newsData["urlToImage"] as? String ?? ""
            
            if (imageUrl != ""){
                let urlImg = NSURL(string: imageUrl )
                
                let data = NSData.init(contentsOf: urlImg! as URL)
                if data != nil {
                    cell.newsImage.image = UIImage(data:data! as Data)
                }

            }
         return cell
        }
        return UITableViewCell()
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        newsTableView.delegate = self
        newsTableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
