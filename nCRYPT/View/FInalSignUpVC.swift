//
//  SignUpVC.swift
//  nCRYPT
//
//  Created by Kartik on 08/06/18.
//  Copyright © 2018 Devsolutions. All rights reserved.
//

import UIKit

class FinalSignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate {
    
    
    //MARK: Outlets
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: Segues
    private let CHAT_SEGUE = "ChatSegueFromSignUp"
    
    
    //MARK: Varibles
    var fullName = String()
    var email = String()
    var password = String()
    
    //MARK: Image Picker
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationController?.title = fullName
        activityIndicator.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        imagePicker.dismiss(animated: true, completion: nil)
        
        userImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
    
    //Hinding Keyboard Functionlity
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    //MARK: Actions
    
    @IBAction func addImageAction(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            
            present(imagePicker,animated: true,completion: nil)
        }
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        activityIndicator.startAnimating()
        AuthenticationProvider.Instance.signUp(email: email, fullName: fullName, password: password, userImage: userImage.image!, signUpHandler: {
            
            (errorMessage) in
            
            if errorMessage != nil{
                
                self.alertTheUser(title: "Error", message: errorMessage!)
                
            }
            
        })
        
        Timer.scheduledTimer(timeInterval: 11, target: self, selector: #selector(self.chatSegueVc), userInfo: nil, repeats: false)
    }
    
    @objc func chatSegueVc(){
        activityIndicator.stopAnimating()
        self.performSegue(withIdentifier: self.CHAT_SEGUE, sender: nil)
    }
    
    //MARK: Private function
    
    private func alertTheUser(title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert,animated: true,completion: nil)
    }
    
}
