//
//  LeaderBoardViewController.swift
//  Stocks-Game
//
//  Created by Fatih Ak on 11/27/18.
//  Copyright © 2018 Fatih Ak. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import Alamofire

class LeaderBoardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var myTableView: UITableView!
    var userChangeList: [String:Double] = [:]
    var leaderboardList: [String] = []
    var currentUser: CurrentUser? = nil
    
    let dbRef = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
        
        self.getLeaderboard{ success in
            self.leaderboardList = self.userChangeList.keys.sorted{self.userChangeList[$0]! > self.userChangeList[$1]!}
            
            self.myTableView.reloadData()
        }
        
        self.myTableView.layer.cornerRadius = 14
        self.myTableView.layer.masksToBounds = true
        self.myTableView.layer.borderColor = UIColor( red: 250/255, green: 250/255, blue:250/255, alpha: 1.0 ).cgColor
        self.myTableView.layer.borderWidth = 2.0
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.myTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.leaderboardList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell", for: indexPath) as? LeaderboardCell{
            var username = self.leaderboardList[indexPath.row]
            cell.usernameLabel.text = username
            cell.rankLabel.text = String(indexPath.row + 1) + "."
            cell.changeLabel.text = percentFormat(value: self.userChangeList[username]!)
            
            if (indexPath.row % 2 == 0){
                let color = UIColor.white
                cell.backgroundColor = color
            }else{
                let color = UIColor(red: 0.08235, green: 0.12941, blue: 0.1725, alpha: 0.05)
                cell.backgroundColor = color
            }
            
            if username == self.currentUser?.name{
                cell.backgroundColor = UIColor(red: 135/266, green: 206/255, blue: 250/255, alpha: 1.0)
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
        
    }
    
    func getLeaderboard(withCompletion completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        
        group.enter()
        self.dbRef.child("Users").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userDict = snapshot.value as! [String:Any]? else{
                return
            }
            for userId in userDict.keys{
                group.enter()
                let user: CurrentUser = CurrentUser(id: userId)
                user.getUserData{ success in
                    guard success else {
                        return
                    }
                    user.getStockData{ success in
                        guard success else { return }
                        let currentWorth: Double = user.currentWorth()
                        let initialWorth: Double = 100000.0
                    
                        let overallChange: Double = currentWorth - initialWorth
                    
                        let overallChangePercent: Double = getPercentage(value: initialWorth, change: overallChange)
                        
                        self.userChangeList[user.name] = overallChangePercent
                        
                        group.leave()
                    }
                }
            }
            group.leave()
        })
        group.notify(queue: .main) {
            completion(true)
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
