//
//  HomePageViewController.swift
//  Discuss
//
//  Created by Harsh Motwani on 10/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class UserProfileViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate {

    var userProfilePageSnapshotListeners: [ListenerRegistration] = []
    
    let db: Firestore = Firestore.firestore()

    let currentUser = Auth.auth().currentUser

    let cellId = "cellId"
    
    let homePostCellId = "homePostCellId"
    
    var posts = [Post]()
    
    var userEmail: String?
    
    var user: User?

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
        
        header.delegate = self
        header.user = user
        
        return header
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        
        return CGSize(width: view.frame.width, height: 200)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isGridView{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfileGridCell
            
            cell.post = posts[posts.count - 1 - indexPath.item]
            
            return cell
            
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomePageCell
            
            cell.snapshotListenerNotSetUp = true
            cell.post = posts[posts.count - 1 - indexPath.item]
            
            return cell
            
        }
        

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        if isGridView {
            
            let width = (view.frame.width-2)/3
            
            return CGSize(width: width , height: width)
            
        } else {
            
            let width = (view.frame.width-1)/2
            
            return CGSize(width: width , height: width)
            
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        
        collectionView.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
        collectionView.register(UserProfileGridCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(HomePageCell.self, forCellWithReuseIdentifier: homePostCellId)
        
        self.navigationItem.title = "Profile"
        
        fetchUser()
        setupLogOutButton()
        
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        for listener in userProfilePageSnapshotListeners {
            
            listener.remove()
            
        }
        
        userProfilePageSnapshotListeners.removeAll()
        
    }
    
    fileprivate func fetchUser(){

        guard let email = userEmail ?? Auth.auth().currentUser?.email else { return }
        
        Firestore.fetchUserWithEmail(email: email) { (user, err) in
            
            if err {
                
               print("could not fetch user")
                return
                
            }
            
            guard let user = user else {
                
                let newProfileViewController = NewProfileViewController()
                newProfileViewController.modalPresentationStyle = .fullScreen
                
                self.present(newProfileViewController, animated: true, completion: nil)
                return
            }
            
            self.user = user
            
            self.collectionView.reloadData()
            
            self.fetchPostsForUser(user: user)
            
            

            
        }
        
//        db.collection("users").document(email).getDocument { (document, err) in
//
//
//            if let err = err{
//
//                print(err)
//                return
//
//            }
//
//            guard let docData = document?.data() else {
//
//                let newProfileViewController = NewProfileViewController()
//                newProfileViewController.modalPresentationStyle = .fullScreen
//
//                self.present(newProfileViewController, animated: true, completion: nil)
//                return
//
//
//            }
//
//            let user = User(dictionary: docData, email: email)
//
//            self.fetchPostsForUser(user: user)
//
//
//        }
        
    }
    
    fileprivate func fetchPostsForUser(user: User){
        
        let snapToSave = db.collection("posts").whereField("userEmail", isEqualTo: user.email).addSnapshotListener { (snapshot, err) in
            
            if let err = err{
                
                print("could not fetch post", err)
                return
                
            }
            
            guard let documentChanges = snapshot?.documentChanges else { return }
            
            for dc in documentChanges {
                
                let document = dc.document
                switch dc.type {
                case .added:
                    
                    let docData = document.data()
                    
                    let post = Post(docData: docData, user: user)
                    
                    self.posts.append(post)
                    
                    self.collectionView.reloadData()
                    
                case .modified:
                    print("document modified:", document.documentID)
                case .removed:
                    print("document removed:", document.documentID)
                default:
                    print("document changed");
                }
                
                
            }
            
        }
        
        userProfilePageSnapshotListeners.append(snapToSave)
        
        
    }
    
    fileprivate func setupLogOutButton(){
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear"), style: .plain, target: self, action: #selector(handleLogOut))
        
    }
    
    
    @objc func handleLogOut(){
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            
            do{
                
               try Auth.auth().signOut()
                
                let loginViewController = LoginViewController()
                
                loginViewController.modalPresentationStyle = .fullScreen
                
                self.present(loginViewController, animated: true, completion: nil)
                
                
            } catch let signOutError as NSError {
              print ("Error signing out: %@", signOutError)
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let post = posts[posts.count - 1 - indexPath.item]
        let postPageViewController = PostPageViewController(collectionViewLayout: UICollectionViewFlowLayout())
        postPageViewController.post = post
        navigationController?.pushViewController(postPageViewController, animated: true)
        
    }
    
    var isGridView: Bool = true
    
    func didChangeToListView() {
        isGridView = false
        collectionView.reloadData()
    }
    
    func didChangeToGridView() {
        isGridView = true
        collectionView.reloadData()
    }
    
    
}

