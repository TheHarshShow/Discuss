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
    let liked: [String]
    let id: String
    let parent: String
    let parentOwner: String
    
    init(docData: [String:Any], commentOwner: User, id: String) {
        
        self.comment = docData["comment"] as? String ?? ""
        self.commentOwner = commentOwner
        self.post = docData["post"] as? String ?? ""
        self.postOwner = docData["postOwner"] as? String ?? ""
        self.timestamp = docData["timestamp"] as? Int64 ?? 0
        self.liked = docData["liked"] as? [String] ?? []
        self.id = id
        self.parent = docData["parent"] as? String ?? ""
        self.parentOwner = docData["parentOwner"] as? String ?? ""
    
    }
    
}
