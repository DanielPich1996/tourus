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
        self.emailField.endEditing(true)
        self.passwordFiled.endEditing(true)
        self.repasswordFiled.endEditing(true)
        
        let email = emailField.text
        let password = passwordFiled.text
        let repassword = repasswordFiled.text
        
        if(email == "" || password == "" || password != repassword){
            if(password != repassword){
                present(consts.general.getCancelAlertController(title: "Registration", messgae: "Please enter same password"), animated: true)
            }
            else{
                present(consts.general.getCancelAlertController(title: "Registration", messgae: "Please enter email and password"), animated: true)
            }
        }
        else{
            self.view.isUserInteractionEnabled = false
            BuisyIndicator.Instance.showBuisyIndicator()
            MainModel.instance.signUp(email!, password!, { (res) in
                if(res) {
                    self.gotoMainview()
                } else {
                    self.present(consts.general.getCancelAlertController(title: "Registration Failed", messgae: "Failed while trying to register. Please try again"), animated: true)
                }
                BuisyIndicator.Instance.hideBuisyIndicator()
                self.view.isUserInteractionEnabled = true
            })
        }
    }
    
    func gotoMainview() {
        //bundle is the place where all of the app's assets and source codes lived in before they compiled
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        //Getting the navigation controller
        guard let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController else {
            return
        }
        //Navigate to the main view
        present(mainVC, animated: true, completion: nil)
    }
}
