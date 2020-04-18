//
//  Post.swift
//  Discuss
//
//  Created by Harsh Motwani on 13/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import Foundation

struct Post {
    
    let postTitle: String
    let description: String
    let timestamp: Int64
    let user: User
    let liked: [String]
    let bookmarked: [String]
    
    init(docData: [String: Any], user: User) {
        
        self.postTitle = docData["postTitle"] as? String ?? ""
        self.description = docData["description"] as? String ?? ""
        self.timestamp = docData["timestamp"] as? Int64 ?? 0
        self.user = user
        self.liked = docData["liked"] as? [String] ?? []
        self.bookmarked = docData["bookmarked"] as? [String] ?? []
    }
    
}
