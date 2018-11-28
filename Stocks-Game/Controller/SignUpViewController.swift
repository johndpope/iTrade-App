//
//  SignUpViewController.swift
//  Stocks-Game
//
//  Created by Fatih Ak on 11/12/18.
//  Copyright © 2018 Fatih Ak. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var passwordVerificationTextField: UITextField!
    
    var userEmail = ""
    var userName = ""
    var userPassword = ""
    var userVerifiedPassWord = ""
    
    let dbRef = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameTextField.delegate = self
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.passwordVerificationTextField.delegate = self
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let name = nameTextField.text else { return }
        guard let verifiedPassword = passwordVerificationTextField.text else { return }
        
        if email == "" || password == "" || name == "" || verifiedPassword == "" {
            let alertController = UIAlertController(title: "Form Error.", message: "Please fill in form completely.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
            
        } else {
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if error == nil {
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = name
                    changeRequest?.commitChanges { (error) in
                        // ...
                    }
                    
                    let userId:String = (Auth.auth().currentUser?.uid as String?)!
                    self.dbRef.child("Users/\(String(describing: userId))/balance").setValue(100000.0)
                    self.dbRef.child("Users/\(String(describing: userId))/stocks").setValue([:])
                    self.dbRef.child("Users/\(String(describing: userId))/name").setValue(name)
                    
                    let today: String = getDate()
                    let todayData: [String : Any] = ["balance": 100000.0, "stocks": [:] ]
                    self.dbRef.child("Users/\(String(describing: userId))/history/\(today)").setValue(todayData)
//                    let newStocks = ["Hello": 0]
//                    self.dbRef.child("Users/\(String(describing: Auth.auth().currentUser?.uid))/stocks").setValue(newStocks)
                    
                    let alertController = UIAlertController(title: "Success!", message: "Your account hs been sucessfully created.", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler:{_ in self.performSegue(withIdentifier: "SignUpToLogIn", sender: self)})
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                } else if password != verifiedPassword {
                    let alertController = UIAlertController(title: "Verification Error.", message: "The two passwords do not match.", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.passwordVerificationTextField.textColor = UIColor.red
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let alertController = UIAlertController(title: "Sign Up Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.emailTextField {
            if textField.text != nil {
                self.userEmail = textField.text!
            }
        } else if textField == self.passwordTextField {
            if textField.text != nil {
                self.userPassword = textField.text!
            }
        } else if textField == self.nameTextField {
            if textField.text != nil {
                self.userName = textField.text!
            }
        } else if textField == self.passwordVerificationTextField {
            if textField.text != nil {
                self.userVerifiedPassWord = textField.text!
            }
        }
    }

}
