//
//  ArticleViewController.swift
//  Stocks-Game
//
//  Created by Fatih Ak on 11/6/18.
//  Copyright © 2018 Fatih Ak. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController {

    @IBOutlet var myWebView: UIWebView!
    var articleURL: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.articleURL != ""){
            let url = URL(string: articleURL)
            self.myWebView.loadRequest(URLRequest(url: url!))
        }
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
