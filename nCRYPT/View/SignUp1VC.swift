//
//  SignUp1VC.swift
//  nCRYPT
//
//  Created by Kartik on 21/08/18.
//  Copyright © 2018 Devsolutions. All rights reserved.
//

import UIKit

class SignUp1VC: UIViewController, UITextFieldDelegate {
    
    
    //MARK: Outlets
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    //MARK: Segue Identifiers
    let finalVcSegue = "FinalVcSegue"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fullNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == finalVcSegue{
            let finalsignUpVc = segue.destination as? FinalSignUpVC
            
            
            finalsignUpVc?.fullName = fullNameTextField.text!
            finalsignUpVc?.email = emailTextField.text!
            finalsignUpVc?.password = passwordTextField.text!
            
            
        }
    }
    
    //MARK: Hide Keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        fullNameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        confirmPasswordTextField.resignFirstResponder()
        
        return true 
    }
    
    //MARK: Functions
    func checkIfValid() -> (Bool, String, String){
        var flag = Bool()
        var title = String()
        var message = String()
        
        if fullNameTextField.text! != "" && emailTextField.text! != "" &&
            passwordTextField.text! != "" && confirmPasswordTextField.text! != ""{
            
            if passwordTextField.text! == confirmPasswordTextField.text!{
                
                if passwordTextField.text!.count < 8 {
                    print("length",passwordTextField.text!.count)
                    flag = false
                    title = "Short Password"
                    message = "Please Enter a password of atleast 8 characters!"
                    
                }
                else{
                    flag = true
                }
            }
            else{
                flag = false
                title = "Password Mismatch"
                message = "Passwords enter DO NOT match!"
                
            }
            
        }
        else{
            flag = false
            title = "All Details are Required"
            message = "You cant Proceed without Filling Up The details You have been asked for!"
        }
        
        return (flag, title, message)
    }
    
    //MARK: Private function
    private func alertTheUser(title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert,animated: true,completion: nil)
    }
    
    @IBAction func next(_ sender: Any){
        var title = String()
        var message = String()
        var flag = Bool()
        
        (flag, title, message) = checkIfValid()
        
        if(!flag){
            alertTheUser(title: title, message: message)
        }
        else{
            performSegue(withIdentifier: finalVcSegue, sender: nil)
        }
        
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
