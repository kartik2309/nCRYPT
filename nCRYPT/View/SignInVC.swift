//
//  SignInVC.swift
//  nCRYPT
//
//  Created by Kartik on 07/06/18.
//  Copyright © 2018 Devsolutions. All rights reserved.
//

import UIKit


class SignInVC: UIViewController, UITextFieldDelegate {
    
    //MARK: Outlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: Variables
    var timer = Timer()
    
    //MARK: Segue

    private let SIGN_UP_SEGUE = "SignUpSegue"
    private let CHAT_SEGUE = "ChatSegueFromSignIn"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailTextField.delegate = self
        passwordTextField.delegate = self
        activityIndicator.isHidden = true
        
        
        if !AuthenticationProvider.Instance.signOut(){
            _ = AuthenticationProvider.Instance.signOut()
        }
        
    }
    
    
    //MARK: UI Controls
    
    //To hide the Keyboard when tapped outside the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //To hide the Keyboard when tapped on return button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        
        return true
    }
    
    //MARK: Actions
    
    @IBAction func signInAction(_ sender: Any) {
        
        if emailTextField.text != "" && passwordTextField.text != ""{
            AuthenticationProvider.Instance.signIn(email: emailTextField.text!, password: passwordTextField.text!, signInHandler: {(errorMessage) in
                
                if errorMessage != nil{
                    self.alertTheUser(title: "Problem with Signing In", message: errorMessage!)
                }
                else{
                    
                    self.activityIndicator.isHidden = false
                    self.activityIndicator.startAnimating()
                    
                    DatabaseProvider.Instance.userDataFromDataBase()
                    UserDefaultHandler.Instance.setCurrentUserId(userId: AuthenticationProvider.Instance.userId())
                    
                    self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.callSegueToChatVc), userInfo: nil, repeats: false)
                    
                }
            })
            
        }
        else{
            self.alertTheUser(title: "Error", message: "Please Enter both Email and Password")
        }
        
    }
    
    
    
    @objc func callSegueToChatVc(){
        timer.invalidate()
        activityIndicator.stopAnimating()
        performSegue(withIdentifier: CHAT_SEGUE, sender: nil)
        
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        
        emailTextField.text = nil
        passwordTextField.text = nil
        
        performSegue(withIdentifier: SIGN_UP_SEGUE, sender: nil)
        
    }
    
    //MARK: Private Functions
    
    private func alertTheUser(title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert,animated: true,completion: nil)
    }
    
}
