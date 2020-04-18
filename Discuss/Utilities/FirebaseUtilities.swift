//
//  FirebaseUtilities.swift
//  Discuss
//
//  Created by Harsh Motwani on 14/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import Foundation
import Firebase

extension Firestore {
    
    static func fetchUserWithEmail(email: String, completion: @escaping (_ user: User?, _ errorInt: Bool) -> ()) {
        
        
        Firestore.firestore().collection("users").document(email).getDocument { (document, err) in
            
            if let err = err {
                
                print("could not fetch user document with error", err)
                completion(nil, true)
                return
                
            }
            
            guard let docData = document?.data() else {
                
                completion(nil, false)
                
                return
                
            }
            let user = User(dictionary: docData, email: email)
            
            completion(user, false)

            
        }
        
    }
    
    static func registerLikeForPost(post: Post){
        
        guard let email = Auth.auth().currentUser?.email else { return }
        
        let db = Firestore.firestore()
        
        db.collection("posts").document("\(post.user.email)-\(post.timestamp)").getDocument { (document, err) in
            
            if let err = err {
                
                print("error fetching document", err)
                return
                
            }
            
            guard var docData = document?.data() else { return }
            
            if docData["liked"] == nil {
                
                var liked = [String]()
                
                if let index = liked.firstIndex(of: email) {
                    
                    liked.remove(at: index)
                    
                } else {
                    
                    liked.append(email)
                    
                }
                
                docData["liked"] = liked
                
                db.collection("posts").document("\(post.user.email)-\(post.timestamp)").setData(docData)
                
            } else {
                
                guard var liked = docData["liked"] as? [String] else { return }
                
                if let index = liked.firstIndex(of: email) {
                    
                    liked.remove(at: index)
                    
                } else {
                    
                    liked.append(email)
                    
                }
                
                
                docData["liked"] = liked
                db.collection("posts").document("\(post.user.email)-\(post.timestamp)").setData(docData)

            }
            
            
        }
        
    }
    
    static func registerBookmarkForPost(post: Post){
        
        guard let email = Auth.auth().currentUser?.email else { return }
        
        let db = Firestore.firestore()
        
        db.collection("posts").document("\(post.user.email)-\(post.timestamp)").getDocument { (document, err) in
            
            if let err = err {
                
                print("error fetching document", err)
                return
                
            }
            
            guard var docData = document?.data() else { return }
            
            if docData["bookmarked"] == nil {
                
                var bookmarked = [String]()
                
                if let index = bookmarked.firstIndex(of: email) {
                    
                    bookmarked.remove(at: index)
                    
                } else {
                    
                    bookmarked.append(email)
                    
                }
                
                docData["bookmarked"] = bookmarked
                
                db.collection("posts").document("\(post.user.email)-\(post.timestamp)").setData(docData)
                
            } else {
                
                guard var bookmarked = docData["bookmarked"] as? [String] else { return }
                
                if let index = bookmarked.firstIndex(of: email) {
                    
                    bookmarked.remove(at: index)
                    
                } else {
                    
                    bookmarked.append(email)
                    
                }
                
                
                docData["bookmarked"] = bookmarked
                db.collection("posts").document("\(post.user.email)-\(post.timestamp)").setData(docData)

            }
            
            
        }
        
        
    }
    
    
}
