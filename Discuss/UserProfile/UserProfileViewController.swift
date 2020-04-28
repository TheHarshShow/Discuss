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

class UserProfileViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate, HomePageCellDelegate {

    
    let db: Firestore = Firestore.firestore()

    let currentUser = Auth.auth().currentUser

    let cellId = "cellId"
    
    let homePostCellId = "homePostCellId"
    
    let bookmarkCellId = "bookmarkCellId"
    
    var posts = [Post]()
    var bookmarkedPosts = [Post]()

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
        
        if isBookmarkView {
            
            return bookmarkedPosts.count
            
        }
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isGridView{
            
            if isBookmarkView {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bookmarkCellId, for: indexPath) as! UserProfileGridCell
                cell.post = bookmarkedPosts[indexPath.item]
                
                return cell
                
            } else {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfileGridCell
                
                cell.post = posts[posts.count - 1 - indexPath.item]
                
                return cell
                
            }
            
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomePageCell
            
            cell.delegate = self
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
        collectionView.register(UserProfileGridCell.self, forCellWithReuseIdentifier: bookmarkCellId)
        
        self.navigationItem.title = "Profile"
        
        fetchUser()
        setupLogOutButton()
        
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
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
            self.fetchBookmarkedPostsForUser(user: user)
            

            
        }
        
    }
    
    fileprivate func fetchPostsForUser(user: User){
        
        db.collection("posts").whereField("userEmail", isEqualTo: user.email).addSnapshotListener { (snapshot, err) in
            
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
                    
                    let docData = document.data()
                    let post = Post(docData: docData, user: user)
                    
                    if let index = self.posts.firstIndex(where: { (postt) -> Bool in
                        
                        return postt.timestamp == post.timestamp
                        
                    }) {
                        
                        self.posts[index] = post
                        
                    }
                    
                    self.collectionView.reloadData()
                    
                case .removed:
                    print("document removed:", document.documentID)
                    
                    let docData = document.data()
                    let post = Post(docData: docData, user: user)
                    
                    if let index = self.posts.firstIndex(where: { (postt) -> Bool in
                        
                        return postt.timestamp == post.timestamp
                        
                    }) {
                        
                        self.posts.remove(at: index)
                        
                    }
                    
                    self.collectionView.reloadData()
                    
                default:
                    print("document changed");
                }
                
                
            }
            
        }
        
        
        
    }
    
    fileprivate func fetchBookmarkedPostsForUser(user: User){
        
        db.collection("posts").whereField("bookmarked", arrayContains: user.email).addSnapshotListener { (snapshot, err) in
            
            if let err =  err {
                
                print("could not fetch bookmarked post snapshot", err)
                return
                
            }
            
            guard let documentChanges = snapshot?.documentChanges else { return }
            
            for dc in documentChanges {
                
                switch dc.type {
                case .added:
                    print("bookmarked post added")
                    let docData = dc.document.data()
                    guard let email = docData["userEmail"] as? String else { return }
                    
                    Firestore.fetchUserWithEmail(email: email) { (user, err) in
                        
                        if err {
                            
                            print("could not fetch user for bookmarked post")
                            return
                            
                        }
                        
                        guard let user = user else { return }
                        
                        let post = Post(docData: docData, user: user)
                        self.bookmarkedPosts.append(post)
                        self.bookmarkedPosts.sort { (p1, p2) -> Bool in
                            
                            return p1.timestamp >= p2.timestamp
                            
                        }
                        
                        self.collectionView.reloadData()
                        
                        
                    }
                    
                case .modified:
                    print("bookmarked post modified")
                    let docData = dc.document.data()
                    guard let email = docData["userEmail"] as? String else { return }
                    guard let timestamp = docData["timestamp"] as? Int64 else { return }
                    
                    Firestore.fetchUserWithEmail(email: email) { (user, err) in
                        
                        if err {
                            
                            print("could not fetch user for bookmarked post")
                            return
                            
                        }
                        
                        guard let user = user else { return }
                        
                        let post = Post(docData: docData, user: user)
                        
                        if let index = self.bookmarkedPosts.firstIndex(where: { (post2) -> Bool in
                            
                            return post2.timestamp == timestamp && post2.user.email == email
                            
                        }) {
                            
                            self.bookmarkedPosts[index] = post
                            
                        }
                        
                        self.collectionView.reloadData()
                        
                        
                    }
                    
                case .removed:
                    print("bookmarked post removed")

                    let docData = dc.document.data()
                    guard let email = docData["userEmail"] as? String else { return }
                    guard let timestamp = docData["timestamp"] as? Int64 else { return }
                    
                    Firestore.fetchUserWithEmail(email: email) { (user, err) in
                        
                        if err {
                            
                            print("could not fetch user for bookmarked post")
                            return
                            
                        }
                        
                        
                        if let index = self.bookmarkedPosts.firstIndex(where: { (post2) -> Bool in
                            
                            return post2.timestamp == timestamp && post2.user.email == email
                            
                        }) {
                            
                            self.bookmarkedPosts.remove(at: index)
                            
                        }
                        
                        self.collectionView.reloadData()
                        
                        
                    }
                    
                default:
                    print("bookmarked post changed")

                }
                
                
            }
            
        }
        
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
        
        if isBookmarkView {
            
            let postPageViewController = PostPageViewController(collectionViewLayout: UICollectionViewFlowLayout())
            postPageViewController.post = bookmarkedPosts[indexPath.item]
            
            navigationController?.pushViewController(postPageViewController, animated: true)
            
        } else {
            
            let postPageViewController = PostPageViewController(collectionViewLayout: UICollectionViewFlowLayout())
            postPageViewController.post = posts[posts.count - 1 - indexPath.item]
                   
            navigationController?.pushViewController(postPageViewController, animated: true)
                   
        }
       
    }
    
    var isGridView: Bool = true
    var isBookmarkView: Bool = false
    
    func didChangeToListView() {
        isGridView = false
        isBookmarkView = false
        collectionView.reloadData()
    }
    
    func didChangeToGridView() {
        isGridView = true
        isBookmarkView = false
        collectionView.reloadData()
    }
    
    func didChangetoBookmarkView(){
        
        isGridView = true
        isBookmarkView = true
        collectionView.reloadData()
    }
    
    func didTapLike(post: Post) {
        
        Firestore.registerLikeForPost(post: post)
        
    }
    
    func didTapBookmark(post: Post) {
        
        Firestore.registerBookmarkForPost(post: post)
        
    }
    
    func handleEditProfile() {
        
        let editProfilePage = EditProfilePage()
        
        self.present(editProfilePage, animated: true, completion: nil)
        
    }
    
    func goToFollowingPage(user: User) {
        
        let followingPage = FollowingPage(collectionViewLayout: UICollectionViewFlowLayout())
        followingPage.user = user
        
        navigationController?.pushViewController(followingPage, animated: true)
        
    }
    
    
    
    
}

