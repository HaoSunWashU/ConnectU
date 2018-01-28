//
//  User.swift
//  ConnectU
//
//  Created by Sun&KK on 11/23/17.
//  Copyright © 2017 CSE438. All rights reserved.
//

import UIKit

class Contact: NSObject {
    var id: String?
    var name: String?
    var email: String?
    var avatarURL: String?
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.avatarURL = dictionary["avatarURL"] as? String
    }
}
