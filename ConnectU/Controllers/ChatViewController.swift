//
//  CharViewController.swift
//  ConnectU
//
//  Created by Sun&KK on 11/17/17.
//  Copyright © 2017 CSE438. All rights reserved.
//

import UIKit
import Firebase

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        fetchUserInfo()
    }
    
    // Storage Messages
    var messages = [Message]()
    var messagesDictionary = [String:Message]()
    var cellId = "chatViewCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        perform(#selector(showSuccess), with: nil, afterDelay: 1)
        messageTableView.dataSource = self
        messageTableView.delegate = self
        //let image = UIImage(named: "pencil")
        //messageTableView.register(ContactCell.self, forCellReuseIdentifier: cellId)
        
        //realize it in storyboard
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(newMessage))
        
        //fetch user information
        perform(#selector(fetchUserInfo), with: nil, afterDelay: 2)
        messageTableView.register(ContactCell.self, forCellReuseIdentifier: cellId)
//        observeUserMessages()
    }
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesReference = Database.database().reference().child("messages").child(messageId)
            
            messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let message = Message(dictionary: dictionary)
                    
                    if let chatPartnerId = message.chatPartnerId() {
                        self.messagesDictionary[chatPartnerId] = message
                        
                        self.messages = Array(self.messagesDictionary.values)
                        self.messages.sort(by: { (message1, message2) -> Bool in
                            return (message1.timestamp?.int32Value) > (message2.timestamp?.int32Value)
                        })
                    }
                    self.timer?.invalidate()
                    print("we just canceled our timer")
                    
                    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                    print("schedule a table reload in 0.1 sec")
                    
                    
                    //this will crash because of background thread, so lets call this on dispatch_async main thread
//                    DispatchQueue.main.async(execute: {
//                        self.messageTableView.reloadData()
//                    })
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    var timer: Timer?
    
    @objc func handleReloadTable() {
        //this will crash because of background thread, so lets call this on dispatch_async main thread
        DispatchQueue.main.async(execute: {
            print("we reloaded the table")
            self.messageTableView.reloadData()
        })
    }
    
    func observeMessages() {
        let ref = Database.database().reference().child("messages")
        ref.observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
                //                self.messages.append(message)
                
                if let toId = message.toId{
                    self.messagesDictionary[toId] = message
                    self.messages = Array(self.messagesDictionary.values)
                    self.messages.sort(by: { (message1, message2) -> Bool in
                        
                        return (message1.timestamp?.int32Value) > (message2.timestamp?.int32Value)
                    })
                    
                }
                //this will crash because of background thread, so lets  this on dispatch_async main thread
                DispatchQueue.main.async(execute: {
                    self.messageTableView.reloadData()
                })
            }
            
        }, withCancel: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ContactCell
        
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        print("did select table cell")
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            let user = Contact(dictionary: dictionary) //Create chat partner information
            user.id = chatPartnerId
            self.showChatControllerForReceiver(user)
            print("aaa")
            
        }, withCancel: nil)
    }
    
    func handleNewMessage() {
        let newMessageController = NewMessageViewController()
        let navController = UINavigationController(rootViewController:newMessageController)
        present(navController,animated:true,completion:nil)
    }
    
    
    @objc func showSuccess()
    {
        ProgressHUD.showSuccess("Success")
    }
    
    //fetch user information from firebase
    @objc func fetchUserInfo() {
        let uid = (Auth.auth().currentUser?.uid)!
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid) // uid is primary key of a user
        usersReference.observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                //show name in the Navigation Item title
                self.navigationItem.title = dictionary["name"] as? String
                
                let currentUser = Contact(dictionary: dictionary)
                //get inforamtion from dictionary
                currentUser.name = dictionary["name"] as? String
                currentUser.email = dictionary["email"] as? String
                currentUser.avatarURL = dictionary["avatarURL"] as? String
                
                self.setupNavbarWithUser(currentUser: currentUser)
            }
        }
        //        guard let uid = Auth.auth().currentUser?.uid else {
        //            //for some reason uid = nil
        //            return
        //        }
        //
        //        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
        //
        //            if let dictionary = snapshot.value as? [String: AnyObject] {
        //                //                self.navigationItem.title = dictionary["name"] as? String
        //
        //                let user = Contact(dictionary: dictionary)
        //                self.setupNavbarWithUser(currentUser: user)
        //            }
        //
        //        }, withCancel: nil)
    }
    
    func setupNavbarWithUser(currentUser: Contact){
        messages.removeAll()
        messagesDictionary.removeAll()
        self.messageTableView.reloadData()
        
        observeUserMessages()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        //titleView.backgroundColor = UIColor.blue
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let avatarImageView = UIImageView()
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 20
        //avatarImageView.clipsToBounds = true
        avatarImageView.layer.masksToBounds = true
        if let avatarURL = currentUser.avatarURL {
            avatarImageView.loadImageUsingCacheWithURL(urlString: avatarURL)
        }
        else{
            avatarImageView.image = UIImage(named: "default-avatar")
        }
        containerView.addSubview(avatarImageView)
        
        //setup constrains for avatarImageView
        avatarImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0).isActive = true
        avatarImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.text = currentUser.name
        nameLabel.textColor = UIColor.white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //setup constrains for avatarImageView
        nameLabel.leftAnchor.constraint(equalTo: avatarImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: avatarImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        //        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
    }
    
    @IBAction func testGoChatLog(_ sender: UIButton) {
        showChatController()
    }
    @objc func showChatController() {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatLogController, animated: true)
        
    }
    func showChatControllerForReceiver(_ receiver: Contact) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.receiver = receiver
        chatLogController.hidesBottomBarWhenPushed = true
        chatLogController.navigationItem.title = receiver.name!
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    //    @objc func newMessage(){
    //        print("newMessage")
    //        let newMessageController = NewMessageViewController()
    //        let navController = UINavigationController(rootViewController: newMessageController)
    //        present(navController, animated: true, completion: nil)
    //    }
    
    func handleLogout() {
        do{
            try Auth.auth().signOut()
        } catch {
            print("error, there was a problem signing out.")
        }
        guard (navigationController?.popToRootViewController(animated: true)) != nil
            else {
                print("No view controllers to pop off")
                return
        }
    }
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        do{
            try Auth.auth().signOut()
        } catch {
            print("error, there was a problem signing out.")
        }
        guard (navigationController?.popToRootViewController(animated: true)) != nil
            else {
                print("No view controllers to pop off")
                return
        }
        
    }
}

