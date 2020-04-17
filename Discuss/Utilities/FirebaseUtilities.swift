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
        
        
        
    }
    
    
}
