//
//  LogInViewController.swift
//
//
//  This is the view controller where users login


import UIKit
import Firebase
import SVProgressHUD

class LogInViewController: UIViewController {

    //Textfields pre-linked with IBOutlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    //go back to welcome view
    @IBAction func goHome(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    // to group message
    // progress needed
    public var UserId = ""
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func logInPressed(_ sender: AnyObject) {
        
        SVProgressHUD.show()
        // Log in the user
        Auth.auth().signIn(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
            if error != nil {
                print(error!)
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: error?.localizedDescription, message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yeah, I know, Close this", style: .default, handler: { (action) in }))
                
                self.present(alert, animated: true, completion: nil)
                
            } else{
                //success
                print("Login Successful!")
                SVProgressHUD.dismiss()
//                ProgressHUD.showSuccess("Login Success!")
                self.perform(#selector(self.showSuccess), with: nil, afterDelay: 0.75)
                //GO TO CHAT VIEW
                let chatViewControllor = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC")
                self.present(chatViewControllor!, animated: true, completion: nil)
            }
        }
        
    }
    @objc func showSuccess()
    {
        ProgressHUD.showSuccess("Success")
    }
    
}  
