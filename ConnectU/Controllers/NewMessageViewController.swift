//
//  NewMessageViewController.swift
//  ConnectU
//
//  Created by Sun&KK on 11/23/17.
//  Copyright © 2017 CSE438. All rights reserved.
//

import UIKit
import Firebase
//this is the contacts table view, by click right nav bar, we can come here, our contacts will show here
class NewMessageViewController: UITableViewController {
    
    let cellId = "cellId"
    var contacts = [Contact]()
    override func viewDidLoad() {
        super.viewDidLoad()
        //add a back button, back to chat view
        //navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
        tableView.register(ContactCell.self, forCellReuseIdentifier: cellId)
        fetchUser()
        
        
        //       navigationController?.
    }
    
    //fetch users in the firebase
    func fetchUser(){
        Database.database().reference().child("users").observe(.childAdded) { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let contact = Contact(dictionary: dictionary)
                contact.id = snapshot.key
                //get inforamtion from dictionary
                contact.name = dictionary["name"] as? String
                contact.email = dictionary["email"] as? String
                contact.avatarURL = dictionary["avatarURL"] as? String
                print(contact.name!, contact.email!)
                //add contact to contacts
                self.contacts.append(contact)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    //    //back to chat view
    //    @objc func handleBack() {
    //        dismiss(animated: true, completion: nil)
    //    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //default tableViewCell
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        
        //customized tableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ContactCell
        
        let contact = contacts[indexPath.row]
        cell.timeLabel.text = ""
        cell.textLabel?.text = contact.name
        cell.detailTextLabel?.text = contact.email
        cell.avatarImageView.image = UIImage(named: "default-avatar")
        //cell.imageView?.image = UIImage(named: "default-avatar")
        //cell.imageView?.contentMode =
        
        //$$$$  GET Avatar from database  $$$$$
        if let avatarURL = contact.avatarURL {
            cell.avatarImageView.loadImageUsingCacheWithURL(urlString: avatarURL)
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  80
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var a = indexPath.row
        let receiverInfo = self.contacts[a]
        print(indexPath.row)
        let ref = Database.database().reference()
        
        //        let usersReference = ref.child("users").child("messageTo") // uid is primary key of a user
        //        //        let values = ["name": self.nameTextfield.text!, "email": self.emailTextfield.text!, "avatarURL": userData?.downloadURL()!]
        //        usersReference.updateChildValues(messageInfo, withCompletionBlock: { (err, ref) in
        //            if let err = err {
        //                print(err)
        //                return
        //            }
        //            //self.dismiss(animated: true, completion: nil)
        //        })
        
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.hidesBottomBarWhenPushed = true
        chatLogController.receiver = receiverInfo
        chatLogController.title = receiverInfo.name
        navigationController?.pushViewController(chatLogController, animated: true)
    }
}
