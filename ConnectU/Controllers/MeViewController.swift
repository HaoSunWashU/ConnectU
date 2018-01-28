//
//  MeViewController.swift
//  ConnectU
//
//  This view is for displaying personla profile, change avatar, name and password
//
//  Created by Sun&KK on 11/23/17.
//  Copyright © 2017 CSE438. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD //processing indicator

class MeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    var email: String?
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    //&&& CONFIRM TO CHANGE PROFILE &&&
    @IBAction func confirmPressed(_ sender: UIButton) {
        //processing indicator appear
        SVProgressHUD.show()
        let uid = (Auth.auth().currentUser?.uid)!
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        let imageName = uid
        let storageRef = Storage.storage().reference().child("Avatar_Images").child("\(imageName).jpg")
        if let avatarImage = self.avatarImageView.image, let uploadData = UIImageJPEGRepresentation(avatarImage, 0.1){
            storageRef.putData(uploadData, metadata: nil, completion: {(metadata, error) in
            if error != nil {
                print(error!)
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: error?.localizedDescription, message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yeah, I know, Close this", style: .default, handler: { (action) in }))
                self.present(alert, animated: true, completion: nil)
                return
            }
            if let avatarImageUrl = metadata?.downloadURL()?.absoluteString{
                
                Auth.auth().signIn(withEmail: self.email!, password: self.passwordTextField.text!) { (user, error) in
                    if error != nil {
                        print(error!)
                        SVProgressHUD.dismiss()
                        let alert = UIAlertController(title: error?.localizedDescription, message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Yeah, I know, Close this", style: .default, handler: { (action) in }))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    } else{ //Vefify User password, reset values in firebase
                        usersReference.setValue(["name": self.nameTextField.text!, "email": self.email!, "avatarURL": avatarImageUrl])
                        ProgressHUD.showSuccess("Success")
                        SVProgressHUD.dismiss()
                    }
                }
            }
            })
        }
        
    }
    
    //$$$ LOGOUT $$$
    @IBAction func logoutPressed(_ sender: UIButton) {
        // Log out the user and send them back to WelcomeViewController
        do{
            try Auth.auth().signOut()
            ProgressHUD.showSuccess("Logout Success!")
            self.performSegue(withIdentifier: "unwindToViewController", sender: self)
        } catch {
            print("error, there was a problem signing out.")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        confirmButton.layer.cornerRadius = 8
        logoutButton.layer.cornerRadius = 8
        confirmButton.layer.masksToBounds = true
        logoutButton.layer.masksToBounds = true
        fetchUserInfo()
        self.passwordTextField.delegate = self
        self.nameTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    func fetchUserInfo() {
        let uid = (Auth.auth().currentUser?.uid)!
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid) // uid is primary key of a user
        usersReference.observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let currentUser = Contact(dictionary: dictionary)
                //get inforamtion from dictionary
//                currentUser.name = dictionary["name"] as? String
//                currentUser.email = dictionary["email"] as? String
//                currentUser.avatarURL = dictionary["avatarURL"] as? String
                
                self.updateDisplay(currentUser: currentUser)
            }
        }
    }
    
    func updateDisplay(currentUser: Contact){
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectAvatar)))
        avatarImageView.isUserInteractionEnabled = true
        //avatarImageView.clipsToBounds = true
        avatarImageView.layer.masksToBounds = true
        
        if let avatarURL = currentUser.avatarURL {
            avatarImageView.loadImageUsingCacheWithURL(urlString: avatarURL)
        }else {
            avatarImageView.image = UIImage(named: "default-avatar")
        }
        email = currentUser.email!
        emailLabel.text = "E-mail: " + currentUser.email!
        nameTextField.text = currentUser.name!
    }
    
    //select image from photo library
    @objc func handleSelectAvatar(){
        print("$$$$$ avatar pressed  $$$$$")
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    //image picker controller (a new view controller pushed on the register view)
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            avatarImageView.image = selectedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancel image picker")
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
