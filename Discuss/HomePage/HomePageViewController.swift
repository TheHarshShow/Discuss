//
//  HomePageViewController.swift
//  Discuss
//
//  Created by Harsh Motwani on 14/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit
import Firebase

class HomePageViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    var posts = [Post]()
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        
        self.navigationItem.title = "Home"
        
        collectionView.register(HomePageCell.self, forCellWithReuseIdentifier: cellId)
        
        setupPosts()
    }
    
    fileprivate func setupPosts(){
        
        guard let currentUser = Auth.auth().currentUser else { return }
        guard let email = currentUser.email else { return }
        
        Firestore.fetchUserWithEmail(email: email) { (user, err) in
            
            if err {
                
                print("could not fetch user document")
                return
                
            }
            
            guard let user = user else { return }
            
            self.fetchPostsWithUser(user: user)
            
        }


        
        
        
    }
    
    fileprivate func fetchPostsWithUser(user: User){
        
        let email = user.email
        
        db.collection("posts").whereField("userEmail", isEqualTo: email).addSnapshotListener { (snapshot, err) in
            
            if let err = err {
                
                print("Couldn't fetch changes for user \(email) with error:", err)
                return
                
            }
            
            guard let documentChanges = snapshot?.documentChanges else { return }
            
            for dc in documentChanges {
                
                switch dc.type {
                case .added:
                    let docData = dc.document.data()
                    self.posts.append(Post(docData: docData, user: user))
                    
                    self.collectionView.reloadData()
                case .modified:
                    print("home document modified")
                case .removed:
                    print("home document removed")
                default:
                    print("document changed")
                }
                
            }
            
        }
        
        
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePageCell
        
        cell.post = posts[posts.count - 1 - indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (view.frame.width-1)/2
        
        return CGSize(width: width , height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
}
