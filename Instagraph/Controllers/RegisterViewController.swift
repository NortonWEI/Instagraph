//
//  RegisterViewController.swift
//  Instagraph
//
//  Created by Margareta  Hardiyanti on 09/09/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class RegisterViewController: UIViewController {

    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    @IBOutlet weak var createAccountButton: PrimaryButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.setupViews()
        self.title = "Sign up"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupViews() {
        self.nameTextField.font = FontObject.sharedInstance.bodyCopy2
        self.nameTextField.textColor = ColorObject.sharedInstance.darkGray1
        
        self.nameTextField.placeholder = "Name"
        self.confirmPasswordTextField.placeholder = "Confirm password"
        self.passwordTextField.placeholder = "Password"
        self.emailAddressTextField.placeholder = "Email address"
        
        self.confirmPasswordTextField.font = FontObject.sharedInstance.bodyCopy2
        self.confirmPasswordTextField.textColor = ColorObject.sharedInstance.darkGray1
        self.passwordTextField.font = FontObject.sharedInstance.bodyCopy2
        self.passwordTextField.textColor = ColorObject.sharedInstance.darkGray1
        self.emailAddressTextField.font = FontObject.sharedInstance.bodyCopy2
        self.emailAddressTextField.textColor = ColorObject.sharedInstance.darkGray1
        
        self.passwordTextField.isSecureTextEntry = true
        self.confirmPasswordTextField.isSecureTextEntry = true
        
        self.createAccountButton.setTitle("Create an account", for: .normal)
        
        self.errorMessageLabel.text = ""
        self.errorMessageLabel.numberOfLines = 0
        self.errorMessageLabel.adjustsFontSizeToFitWidth = true
        self.errorMessageLabel.minimumScaleFactor = 0.5
    }
    
    // Handles registration request
    @IBAction func registerButtonClicked(_ sender: UIButton) {
        if isRegisterFormValid() {
            clearErrorMessage()
            let spinner = UIViewController.displaySpinner(onView: self.view)
            
            UserManager.share.register(
                email: self.emailAddressTextField.text!,
                name: self.nameTextField.text!,
                password: self.passwordTextField.text!,
                callback: { (error) in
                    // Check registration error
                    if error != nil {
                        self.displayErrorMessage(error!.localizedDescription)
                        UIViewController.removeSpinner(spinner: spinner)
                        return
                    }
                    
                    // Enter main UI
//                    MainMenuViewController.enter()
                    self.navigationController?.popViewController(animated: true)
                }
            )
        }
    }
    
    // Auto-lowercase name input
    @IBAction func nameTextFieldEditChanged(_ sender: Any) {
        nameTextField.text = nameTextField.text?.lowercased()
    }
    
    // Check if the register form is valid
    func isRegisterFormValid() -> Bool {
        let email = self.emailAddressTextField.text
        let name = self.nameTextField.text
        let password = self.passwordTextField.text
        let confirmPassword = self.confirmPasswordTextField.text
        
        if isFieldEmpty(name!) {
            displayFieldError("Name", .emptyField)
            return false
        }
        
        if isNameValid(name!) {
            displayFieldError("Name", .invalidName )
            return false
        }
        
        if isFieldEmpty(email!) {
            displayFieldError("Email", .emptyField)
            return false
        }
        
        if isEmailInvalid(email!) {
            displayFieldError("Email", .invalidFormat)
            return false
        }
    
        if isPasswordWeak(password!) {
            displayFieldError("Password", .weakPassword)
            return false
        }
        
        if isFieldEmpty(confirmPassword!) {
            displayFieldError("Confirm password", .emptyField)
            return false
        }
        
        if password != confirmPassword {
            displayFieldError(nil, .passwordMismatch)
            return false
        }
        
        return true
    }
    
    // Check if the text field is empty
    func isFieldEmpty(_ field: String) -> Bool {
        return field.trimmingCharacters(in: .whitespacesAndNewlines) == ""
    }
    
    // Check if the name field is valid
    func isNameValid(_ field: String) -> Bool {
        let nonAllowedCharsSet = NSCharacterSet.alphanumerics.inverted
        return field.rangeOfCharacter(from: nonAllowedCharsSet) != nil
    }
    
    // Check if the password is not strong enough
    func isPasswordWeak(_ field: String) -> Bool {
        return field.count < 6
    }
    
    // Types of help text for invalid field indication
    enum helpTextType {
        case emptyField, passwordMismatch, weakPassword, invalidFormat, invalidName
    }
    
    // Reset error message label
    func clearErrorMessage() {
        self.errorMessageLabel.text = ""
    }
    
    // Display text on error message label
    func displayErrorMessage(_ errorMessage: String) {
        self.errorMessageLabel.text = errorMessage
    }
    
    func displayFieldError(_ fieldName: String?, _ errorType: helpTextType) {
        var message: String
        
        switch errorType {
            case .emptyField:
                message = " is required"
            case .invalidName:
                message = " can only have letters and numbers"
            case .invalidFormat:
                message = " has incorrect format"
            case .weakPassword:
                message = " is too weak (min 6 chars)"
            case .passwordMismatch:
                message = "Passwords does not match"
        }
        
        displayErrorMessage(fieldName != nil ? fieldName! + message : message)
    }
    
    // Credit to https://medium.com/@darthpelo/email-validation-in-swift-3-0-acfebe4d879a
    func isEmailInvalid(_ email: String) -> Bool {
        let emailRegEx = "(?:[a-zA-Z0-9!#$%\\&‘*+/=?\\^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}" +
        "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
        "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-" +
        "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5" +
        "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
        "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return !emailTest.evaluate(with: email)
    }
}
