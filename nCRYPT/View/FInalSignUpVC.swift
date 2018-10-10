//
//  SignUpVC.swift
//  nCRYPT
//
//  Created by Kartik on 08/06/18.
//  Copyright © 2018 Devsolutions. All rights reserved.
//

import UIKit

class FinalSignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate, getEmailVerificationMessage {
    
    //MARK: Outlets
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var selectImageButton: UIButton!
    
    //MARK: Varibles
    var fullName = String()
    var email = String()
    var password = String()
    var errorInEmailVerfication: Error?
    
    //MARK: Image Picker
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationController?.title = fullName
        activityIndicator.isHidden = true
        signUpButton.layer.cornerRadius = 30
        
        userImage.layer.cornerRadius = userImage.frame.size.height/2
        userImage.clipsToBounds = true
        
        selectImageButton.layer.cornerRadius = selectImageButton.frame.size.height/2
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
        
        Timer.scheduledTimer(timeInterval: 11, target: self, selector: #selector(self.signInSegue), userInfo: nil, repeats: false)
        
    }
    
    @objc func signInSegue(){
        AuthenticationProvider.Instance.sendEmailVerification()
        getErrorMessage()
        activityIndicator.stopAnimating()
    }
    
    //MARK: Delegate Functins
    func getMessage(error: Error?) {
        self.errorInEmailVerfication = error
    }
    
    
    //MARK: Private function
    
    private func alertTheUser(title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: {
            _ in
            CATransaction.setCompletionBlock({
                let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let signInVc = storyBoard.instantiateViewController(withIdentifier: "SignInVc") as! SignInVC
                self.present(signInVc, animated: true, completion: nil)
            })
        })
        alert.addAction(ok)
        present(alert,animated: true,completion: nil)
    }
    
    private func getErrorMessage(){
        
        if errorInEmailVerfication != nil{
            alertTheUser(title: "Error", message: "Unknown error occured")
        }
        else{
            alertTheUser(title: "Verify your email", message: "Kindly verifiy your email. A link has been sent to your email.")
            
        }
    }
    
}
