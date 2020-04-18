//
//  FollowingPage.swift
//  Discuss
//
//  Created by Harsh Motwani on 18/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit
import Firebase

class FollowingPage: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var user: User? {
        
        didSet {
            
            fetchFollowing()
            
        }
        
    }
    
    let db = Firestore.firestore()
    
    let cellId = "cellId"
    
    var users = [User]()
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 66)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchCell
        
        cell.user = users[indexPath.item]
        
        return cell
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "following"
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .systemBackground
        collectionView.register(SearchCell.self, forCellWithReuseIdentifier: cellId)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let userViewController = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
        userViewController.user = self.users[indexPath.item]
        userViewController.userEmail = self.users[indexPath.item].email
        self.navigationController?.pushViewController(userViewController, animated: true)
        
    }
    
    fileprivate func fetchFollowing(){
        
        guard let user = self.user else { return }
        
        db.collection("following").document(user.email).addSnapshotListener { (document, err) in
            
            if let err = err {
                
                print("could not fetch following page snapshot", err)
                return
                
            }
            
            if document?.exists ?? false {
                
                guard let docData = document?.data() as? [String: Bool] else { return }
                
                for user in self.users {
                    
                    if docData[user.email] == nil || docData[user.email] == false {
                        
                        if let index = self.users.firstIndex(where: { (user2) -> Bool in
                            
                            return user2.email == user.email
                            
                        }) {
                            self.users.remove(at: index)
                            print("REMOVED", self.users)
                        }
                        
                    }
                    
                }
                
                self.collectionView.reloadData()
                
                
                for (k,v) in docData {
                    
                    if v {
                        
                        if self.users.contains(where: { (user) -> Bool in
                            
                            return user.email == k
                            
                        }) == false {
                            
                            
                            
                            Firestore.fetchUserWithEmail(email: k) { (user, err) in
                                
                                if err {
                                    
                                    print("could not fetch user on following page")
                                    return
                                    
                                }
                                
                                guard let user = user else { return }
                                self.users.append(user)
                                
                                self.collectionView.reloadData()
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
}
