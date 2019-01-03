

import UIKit

class RegisterViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordFiled: UITextField!
    @IBOutlet weak var repasswordFiled: UITextField!
    @IBOutlet var viewcontainer: UIView!
    
    override func viewDidLoad() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(RegisterViewController.tapDetected))
        viewcontainer.addGestureRecognizer(singleTap)
    }
    
    @objc func tapDetected() {
        self.emailField.endEditing(true)
        self.passwordFiled.endEditing(true)
        self.repasswordFiled.endEditing(true)
    }
    
    @IBAction func OnLoginTapped(_ sender: Any) {
        emailField.text = ""
        passwordFiled.text = ""
        repasswordFiled.text = ""
    }
    
    @IBAction func onRegisterTapped(_ sender: Any) {
        let email = emailField.text
        let password = passwordFiled.text
        let repassword = repasswordFiled.text
        
        if(email == "" || password == "" || password != repassword){
            if(password != repassword){
                present(Consts.General.getCancelAlertController(title: "Registration", messgae: "Please enter same passwords"), animated: true)
            }
            else{
                present(Consts.General.getCancelAlertController(title: "Registration", messgae: "Please enter Email or Password"), animated: true)
            }
        }
        else{
            
            MainModel.instance.signUp(email!, password!, { (res) in
                if(res) {
                    self.gotoMainview()
                } else {
                    self.present(Consts.General.getCancelAlertController(title: "Registration", messgae: "Failed while trying to register. Please try again"), animated: true)
                }
            })
        }
    }
    
    func gotoMainview() {
        //bundle is the place where all of the app's assets and source codes lived in before they compiled
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        //Getting the navigation controller
        guard let mainNavigationVC = mainStoryboard.instantiateViewController(withIdentifier: "MainNavigationController") as? MainNavigationController else {
            return
        }
        //Navigate to the main view
        present(mainNavigationVC, animated: true, completion: nil)
    }
}




/*  guard
 let email = emailField.text,
 email != "",
 
 let password = passwordFiled.text,
 password != "",
 
 let repassword = repasswordFiled.text,
 repassword != "",
 
 password == repassword
 
 else {
 present(Consts.General.getCancelAlertController(title: "Registration", messgae: "Please enter Email or Password"), animated: true)
 return
 }
 
 Model.instance.signUp(email, password, { (res) in
 
 if(res) {
 self.performSegue(withIdentifier: "registerSugue", sender: nil)
 } else {
 self.present(Consts.General.getCancelAlertController(title: "Registration", messgae: "Failed while trying to register. Please try again"), animated: true)
 }
 })
 */
