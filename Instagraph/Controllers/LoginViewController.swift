//
//  ViewController.swift
//  Instagraph
//
//  Created by 魏文洲 on 8/9/2018.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: PrimaryButton!
    @IBOutlet weak var signupButton: SecondaryButton!
    @IBOutlet weak var needAccountText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
         self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    func setupViews() {
        self.emailTextField.font = FontObject.sharedInstance.bodyCopy1
        self.emailTextField.placeholder = "email address"
        self.emailTextField.textColor = ColorObject.sharedInstance.darkGray1
        
        self.passwordTextField.placeholder = "password"
        self.passwordTextField.font = FontObject.sharedInstance.bodyCopy1
        self.passwordTextField.textColor = ColorObject.sharedInstance.darkGray1
        self.passwordTextField.isSecureTextEntry = true
        self.loginButton .setTitle("Login", for: .normal)
        self.signupButton.setTitle("Sign up", for: .normal)
        self.needAccountText.font = FontObject.sharedInstance.bodyCopy2
        self.needAccountText.text = "Don't have any account?"
        self.needAccountText.textColor = ColorObject.sharedInstance.darkGray1
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginTapped(_ sender: Any) {
        let email = self.emailTextField.text
        let password = self.passwordTextField.text

        // Check if any field is empty
        if email == "" || password == "" {
            displayAlert(title: "Field Missing", message: "Please enter email/password")
        }
        
        let spinner = UIViewController.displaySpinner(onView: self.view)
        
        UserManager.share.signIn(with: email!, password: password!, callback: { (error) in
            // Check error
            guard error == nil else {
                self.displayAlert(title: "Login Failed", message: error!.localizedDescription)
                UIViewController.removeSpinner(spinner: spinner)
                return
            }
            
            UserRelationManager.share.initializeFollowingsData(onComplete: { (error) in
                guard error == nil else {
                    self.displayAlert(title: "Login Failed", message: error!.localizedDescription)
                    UIViewController.removeSpinner(spinner: spinner)
                    return
                }
                
                UIViewController.removeSpinner(spinner: spinner)
                MainMenuViewController.enter()
            })
        })
    }
    
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    static func enter() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        UIApplication.shared.keyWindow?.rootViewController  = viewController
    }
}

