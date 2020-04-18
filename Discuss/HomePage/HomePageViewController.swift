//
//  HomePageViewController.swift
//  Discuss
//
//  Created by Harsh Motwani on 14/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit
import Firebase

class HomePageViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HomePageCellDelegate {


    let cellId = "cellId"
    
    var posts = [Post]()
    
    let db = Firestore.firestore()
    
    let refreshControl = UIRefreshControl()
        
    let currentUser = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("home page loaded")
        
        self.collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        
        self.navigationItem.title = "Home"
        
        collectionView.register(HomePageCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        fetchFollowing()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("home page appeared")
        
    }
    
    
    fileprivate func fetchFollowing(){
        
        guard let email = Auth.auth().currentUser?.email else { return }
        
        
        db.collection("following").document(email).addSnapshotListener { (document, err) in
            guard let docData = document?.data() as? [String:Bool] else { return }
            
            for (k,v) in docData {
                
                if v {
                    
                    
                    Firestore.fetchUserWithEmail(email: k) { (user, err) in
                        
                        if err {
                            
                            print("couldn't fetch user")
                            return
                            
                        }
                        
                        guard let user = user else { return }
                        self.fetchPostsWithUser(user: user)
                        
                    }
                    
                }
                
            }
            
            self.collectionView.refreshControl?.endRefreshing()
        }
        
        
//        db.collection("following").document(email).getDocument(completion: { (document, err) in
//            guard let docData = document?.data() as? [String:Bool] else { return }
//
//            for (k,v) in docData {
//
//                if v {
//
//                    Firestore.fetchUserWithEmail(email: k) { (user, err) in
//
//                        if err {
//
//                            print("couldn't fetch user")
//                            return
//
//                        }
//
//                        guard let user = user else { return }
//                        self.fetchPostsWithUser(user: user)
//
//                    }
//
//                }
//
//            }
//            self.collectionView.refreshControl?.endRefreshing()
//
//        })
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
                    let post = Post(docData: docData, user: user)
                                        
//                    self.posts.append(post)
                    
                    if self.posts.contains(where: { (post1) -> Bool in
                        
                        return post1.timestamp == post.timestamp
                        
                    }) == false {

                        self.posts.append(post)
                        
                    }
                    
                    self.posts.sort { (p1, p2) -> Bool in
                        
                        return p1.timestamp <= p2.timestamp
                        
                    }
                    
                    self.collectionView.reloadData()
                case .modified:
                    
                    print("home document modified")
                    let docData = dc.document.data()
                    let post = Post(docData: docData, user: user)
                    
                    if let index = self.posts.firstIndex(where: { (postt) -> Bool in
                        
                        return postt.timestamp == post.timestamp
                        
                    }) {
                        
                        self.posts[index] = post
                        
                    }
                    
                    self.collectionView.reloadData()
                    
                case .removed:
                    print("home document removed")
                    
                    let docData = dc.document.data()
                    let post = Post(docData: docData, user: user)
                    
                    if let index = self.posts.firstIndex(where: { (postt) -> Bool in
                        
                        return postt.timestamp == post.timestamp
                        
                    }){
                        
                        self.posts.remove(at: index)
                        
                    }
                    

                    self.collectionView.reloadData()
                    
                    
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
        cell.delegate = self
        
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
    
    @objc func handleRefresh(){
        
        posts.removeAll()
        
        collectionView.reloadData()

        fetchFollowing()
        
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let postPageViewController = PostPageViewController(collectionViewLayout: UICollectionViewFlowLayout())
        
        postPageViewController.post = posts[posts.count - 1 - indexPath.item]
        
        navigationController?.pushViewController(postPageViewController, animated: true)
        
        
    }
    
    func didTapLike(post: Post) {
        print("Like Button Tapped", post.postTitle)
        
        Firestore.registerLikeForPost(post: post)
        
    }
    
    func didTapBookmark(post: Post) {
        
        print("bookmark button tapped")
        
        Firestore.registerBookmarkForPost(post: post)
        
    }
    
    
}
