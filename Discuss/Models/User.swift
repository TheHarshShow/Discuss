//
//  User.swift
//  Discuss
//
//  Created by Harsh Motwani on 14/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import Foundation

struct User
{
    
    let email: String
    let displayName: String
    let description: String
    
    init(dictionary: [String:Any], email:String) {
        
        self.email = email
        self.displayName = dictionary["displayName"] as? String ?? ""
        self.description = dictionary["description"] as? String ?? ""
        
    }
    
    
}
