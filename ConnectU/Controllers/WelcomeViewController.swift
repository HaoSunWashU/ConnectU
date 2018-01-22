//
//  WelcomeViewController.swift
//  Connect
//
//  This is the welcome view controller - the first thign the user sees
//

import UIKit
import Firebase


class WelcomeViewController: UIViewController {

    @IBAction func loginButtonPressed(_ sender: UIButton) {
        let loginViewControllor = storyboard?.instantiateViewController(withIdentifier: "loginVC")
            present(loginViewControllor!, animated: true, completion: nil)
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        let registerViewControllor = storyboard?.instantiateViewController(withIdentifier: "registrationVC")
        present(registerViewControllor!, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        perform(#selector(checkIfUserIsLoggedIn), with: nil, afterDelay: 0)
        
//        let viewControllor = storyboard?.instantiateViewController(withIdentifier: "TabBarVC")
//
//        //enter the welcome view, first we should check if user is logged in
//        if Auth.auth().currentUser?.uid != nil{
//            //GO TO CHAT VIEW
//            print("**** TO TO CHAT VIEW *****")
//            ProgressHUD.showSuccess("Already Login!")
//            present(viewControllor!, animated: true, completion: nil)
//        }
        
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkIfUserIsLoggedIn()
    }
    
    @objc func checkIfUserIsLoggedIn(){
        // if user is logged in, chating view will appear
        if Auth.auth().currentUser?.uid != nil{
            //GO TO CHAT VIEW
            print("******TO TO CHAT VIEW******")
            ProgressHUD.showSuccess("Already Login!")
            let viewControllor = storyboard?.instantiateViewController(withIdentifier: "TabBarVC")
            present(viewControllor!, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
