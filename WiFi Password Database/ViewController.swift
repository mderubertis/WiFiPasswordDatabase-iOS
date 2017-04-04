//
//  ViewController.swift
//  WiFi Password Database
//
//  Created by Michael De Rubertis on 2017-02-22.
//  Copyright © 2017 ApexTech Solutions. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UITextFieldDelegate {
    let api: String = "https://www.solutions-apex.tk/wifi-pass-db/login.php"
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    func getUser(email: String, password: String, completionHandler: @escaping (Bool?, NSDictionary?, String?) -> ()) {
        Alamofire.request(api, method: .post, parameters: ["email": email, "password": password])
            .responseJSON { response in
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling POST")
                    completionHandler(true, nil, response.result.description)
                    return
                }
                // make sure we got some JSON since that's what we expect
                guard let json = response.result.value as? [String: Any] else {
                    let jsonResponse = response.result.value as? String
                    completionHandler(true, nil, jsonResponse)
                    return
                }
                guard let user = json["user"] as? [String: Any] else {
                    completionHandler(true, nil, json["error_msg"] as? String)
                    return
                }
                // get and print the status
                guard let uid = json["uid"] as? String else {
                    completionHandler(true, nil, json["error_msg"] as? String)
                    return
                }
                
                guard let name = user["name"] as? String else {
                    completionHandler(true, nil, json["error_msg"] as? String)
                    return
                }
                
                guard let email = user["email"] as? String else {
                    completionHandler(true, nil, json["error_msg"] as? String)
                    return
                }
                
                let userInfo: NSDictionary = [
                    "uid": uid,
                    "name": name,
                    "email": email]
                
                completionHandler(false, userInfo, nil)
        }
    }
    
    @IBAction func emailContinue(_ sender: Any) {
        self.passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func loginKeyboardClicked(_ sender: Any) {
        getUser(email: emailTextField.text!, password: passwordTextField.text!) { error, userInfo, errorMsg in
            if error! {
                print("operation failed: \(errorMsg!)")
                let alertController = UIAlertController(title: "Login Error!", message: "\(errorMsg!)", preferredStyle: UIAlertControllerStyle.alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                    self.passwordTextField.text = ""
                    self.passwordTextField.becomeFirstResponder()
                }
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                
                let name = userInfo!["name"] as! String
                let email = userInfo!["email"] as! String
                let uid = userInfo!["uid"] as! String
                
                if Database.instance.addUser(uname: name, uemail: email, uuid: uid) != nil {
                    let id: Int64 = Int64(Database.instance.getUsers().count)
                    print(Database.instance.getUser(tid: id))
                }
            }
            
            return
        }
    }
    
    @IBAction func loginClicked(_ sender: Any) {
        getUser(email: emailTextField.text!, password: passwordTextField.text!) { error, userInfo, errorMsg in
            if error! {
                print("operation failed: \(errorMsg!)")
                let alertController = UIAlertController(title: "Login Error!", message: "\(errorMsg!)", preferredStyle: UIAlertControllerStyle.alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                    self.passwordTextField.text = ""
                    self.passwordTextField.becomeFirstResponder()
                }
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                
                let name = userInfo!["name"] as! String
                let email = userInfo!["email"] as! String
                let uid = userInfo!["uid"] as! String
                
                if Database.instance.addUser(uname: name, uemail: email, uuid: uid) != nil {
                    let id: Int64 = Int64(Database.instance.getUsers().count)
                    print(Database.instance.getUser(tid: id))
                }
            }
            
            return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = Database.instance.getUsers()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}

