//
//  Comment.swift
//  Discuss
//
//  Created by Harsh Motwani on 16/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import Foundation

struct Comment {
    
    let comment: String
    let commentOwner: User
    let post: String
    let postOwner: String
    let timestamp: Int64
    
    init(docData: [String:Any], commentOwner: User) {
        
        self.comment = docData["comment"] as? String ?? ""
        self.commentOwner = commentOwner
        self.post = docData["post"] as? String ?? ""
        self.postOwner = docData["postOwner"] as? String ?? ""
        self.timestamp = docData["timestamp"] as? Int64 ?? 0
        
    }
    
}
