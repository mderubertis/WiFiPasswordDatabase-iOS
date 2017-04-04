//
//  User.swift
//  WiFi Password Database
//
//  Created by Michael De Rubertis on 2017-04-03.
//  Copyright © 2017 ApexTech Solutions. All rights reserved.
//

import Foundation

class User {
    let id: Int64?
    var name: String
    var email: String
    var uid: String
    
    init(id: Int64) {
        self.id = id
        name = ""
        email = ""
        uid = ""
    }
    
    init(id: Int64, name: String, email: String, uid: String) {
        self.id = id
        self.name = name
        self.email = email
        self.uid = uid
    }
}
