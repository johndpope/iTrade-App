//
//  LogInViewController.swift
//  Stocks-Game
//
//  Created by Fatih Ak on 11/12/18.
//  Copyright © 2018 Fatih Ak. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth


class LogInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    
    var currentUser: CurrentUser? = nil
    var userEmail = ""
    var userPassword = ""
    
    override func viewDidLoad() {
        
        let statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
        let statusBarColor = UIColor(red: 21/255, green: 155/255, blue: 27/255, alpha: 1.0)
        statusBarView?.backgroundColor = statusBarColor
        
        super.viewDidLoad()
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
        let statusBarColor = UIColor(red: 21/255, green: 155/255, blue: 27/255, alpha: 1.0)
        statusBarView?.backgroundColor = statusBarColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
        let statusBarColor = UIColor.white.withAlphaComponent(0.0)
        statusBarView?.backgroundColor = statusBarColor
    }

    @IBAction func logInPressed(_ sender: Any) {
        guard let emailText = emailTextField.text else { return }
        guard let passwordText = passwordTextField.text else { return }
        
        if emailText == "" || passwordText == "" {
            //Alert to tell the user that there was an error because they didn't fill anything in the textfields
            let alertController = UIAlertController(title: "Log In Error", message: "Please enter an email and password.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            Auth.auth().signIn(withEmail: emailText, password: passwordText) { (user, error) in
                if error == nil{
                    self.currentUser = CurrentUser()
                    
                    
                    self.currentUser?.getUserData{ success in
                        guard success else { return }
                        self.performSegue(withIdentifier: "LogInToDashboard" , sender: self)
                    }
                }else{
                    let alertController = UIAlertController(title: "Log In Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.emailTextField {
            if textField.text != nil {
                self.userEmail = textField.text!
            }
        } else {
            if textField.text != nil {
                self.userPassword = textField.text!
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "LogInToSignUp" {
            let tabVC = segue.destination as! UITabBarController
            
            let portfolioNavVC = tabVC.viewControllers!.first as! UINavigationController
            let portfolio = portfolioNavVC.topViewController as! PortfolioViewController
            portfolio.currentUser = self.currentUser
            
            let exploreNavVC = tabVC.viewControllers![1] as! UINavigationController
            let explore = exploreNavVC.topViewController as! StockTableViewController
            explore.currentUser = self.currentUser
            
            let leaderNavVC = tabVC.viewControllers![2] as! UINavigationController
            let leaderboard = leaderNavVC.topViewController as! LeaderBoardViewController
            leaderboard.currentUser = self.currentUser
            
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
