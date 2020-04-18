//
//  LikePageViewController.swift
//  Discuss
//
//  Created by Harsh Motwani on 18/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit
import Firebase

class LikePageViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    var posts = [Post]()
    
    let db = Firestore.firestore()
    
    let currentUser = Auth.auth().currentUser
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfileGridCell
        
        cell.post = posts[indexPath.item]
        
        return cell
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (self.view.frame.width-2)/3;
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 1
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let postPageViewController = PostPageViewController(collectionViewLayout: UICollectionViewFlowLayout())
        postPageViewController.post = posts[indexPath.item]
        navigationController?.pushViewController(postPageViewController, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Liked"
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.backgroundColor = .systemBackground
        collectionView.register(UserProfileGridCell.self, forCellWithReuseIdentifier: cellId)
        
        fetchLikedPosts()
        
    }
    
    fileprivate func fetchLikedPosts(){
        
        guard let email = currentUser?.email else { return }
        
        db.collection("posts").whereField("liked", arrayContains: email).addSnapshotListener { (snapshot, err) in
            
            if let err = err {
                
                print("could not fetch like snapshot", err)
                return
                
            }
            
            guard let documentChanges = snapshot?.documentChanges else { return }
            
            for dc in documentChanges {
                
                switch dc.type {
                case .added:
                    
                    let docData = dc.document.data()
                    
                    guard let email = docData["userEmail"] as? String else { return }
                    
                    Firestore.fetchUserWithEmail(email: email) { (user, err) in
                        
                        if err {
                            
                            print("couldn't fetch user on like page")
                            return
                            
                        }
                        
                        guard let user = user else { return }
                        
                        let post = Post(docData: docData, user: user)

                        self.posts.append(post)
                        
                        self.posts.sort { (p1, p2) -> Bool in
                            
                            return p1.timestamp >= p2.timestamp
                            
                        }
                        
                        self.collectionView.reloadData()
                        
                    }
                    
                    
                    
                case .modified:
                
                    print("Like Page Document Modified")
                    
                    let docData = dc.document.data()
                    
                    guard let email = docData["userEmail"] as? String else { return }
                    
                    Firestore.fetchUserWithEmail(email: email) { (user, err) in
                        
                        if err {
                            
                            print("couldn't fetch user on like page")
                            return
                            
                        }
                        
                        guard let user = user else { return }
                        let post = Post(docData: docData, user: user)
                        
                        
                        if let index = self.posts.firstIndex(where: { (postt) -> Bool in
                            return (postt.user.email == user.email && postt.timestamp == post.timestamp)
                        }) {
                            
                            self.posts[index] = post
                            
                        }
                        
                        
                        self.collectionView.reloadData()
                        
                    }
                    
                    
                case .removed:
                    
                    print("Like Page Document Removed")
                    
                    let docData = dc.document.data()
                    
                    guard let email = docData["userEmail"] as? String else { return }
                    
                    Firestore.fetchUserWithEmail(email: email) { (user, err) in
                        
                        if err {
                            
                            print("couldn't fetch user on like page")
                            return
                            
                        }
                        
                        guard let user = user else { return }
                        let post = Post(docData: docData, user: user)
                        
                        
                        if let index = self.posts.firstIndex(where: { (postt) -> Bool in
                            return (postt.user.email == user.email && postt.timestamp == post.timestamp)
                        }) {
                            
                            self.posts.remove(at: index)
                            
                        }
                        
                        
                        self.collectionView.reloadData()
                        
                    }
                    
                    
                default:
                    
                    print("posts changed on like page")
                    
                }
                
                
            }
            
            
        }
        
    }
    
    
}
