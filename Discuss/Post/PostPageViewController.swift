//
//  PostPageViewController.swift
//  Discuss
//
//  Created by Harsh Motwani on 16/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit
import Firebase

class PostPageViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var postPageSnapshotListeners: [ListenerRegistration] = []
    
    var post: Post? {
        
        didSet {
            
            
            
        }
        
    }
    
    var comments: [Comment] = []
    
    let headerId = "postPageHeader"
    
    let db = Firestore.firestore()
    
    let currentUser = Auth.auth().currentUser
    
    let commentTextField : UITextField = {
        
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.borderStyle = .roundedRect
        tf.placeholder = "Comment..."
        
        return tf
        
    }()
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! PostPageHeader
        
        guard let post = post else { return header }
        
        header.post = post
        header.userButton.addTarget(self, action: #selector(handleShowUser), for: .touchUpInside)
//        if post.liked.contains(currentUser?.email ?? "") {
//    
//            header.likeButton.setImage(UIImage(named: "like_selected"), for: .normal)
//        }
//        
        return header
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 280)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Post"
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        collectionView.register(PostPageHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.tabBar.isHidden = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = false
        
    }
    
    @objc func handleShowUser(){
        
        
        let userProfileViewController = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileViewController.userEmail = post?.user.email
        
        navigationController?.pushViewController(userProfileViewController, animated: true)
        
    }
    
    var _inputAccessoryView: UIView!

    override var inputAccessoryView: UIView? {

        if _inputAccessoryView == nil {

            _inputAccessoryView = CustomView()
            _inputAccessoryView.backgroundColor = .secondarySystemBackground

            let sendButton = UIButton()
            sendButton.addTarget(self, action: #selector(handlePostComment), for: .touchUpInside)
            
            _inputAccessoryView.addSubview(commentTextField)
            _inputAccessoryView.addSubview(sendButton)
            
            _inputAccessoryView.autoresizingMask = .flexibleHeight

            sendButton.translatesAutoresizingMaskIntoConstraints = false
            
            sendButton.setTitle("Send", for: .normal)
            sendButton.setTitleColor(.label, for: .normal)
            sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            
            sendButton.trailingAnchor.constraint(equalTo: _inputAccessoryView.trailingAnchor, constant: -8).isActive = true
            sendButton.topAnchor.constraint(equalTo: _inputAccessoryView.topAnchor, constant: 8).isActive = true
            sendButton.bottomAnchor.constraint(equalTo: _inputAccessoryView.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
            sendButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
            
            commentTextField.leadingAnchor.constraint(
                equalTo: _inputAccessoryView.leadingAnchor,
                constant: 8
            ).isActive = true

            commentTextField.trailingAnchor.constraint(
                equalTo: sendButton.leadingAnchor,
                constant: -8
            ).isActive = true

            commentTextField.topAnchor.constraint(
                equalTo: _inputAccessoryView.topAnchor,
                constant: 8
            ).isActive = true

            // this is the important part :

            commentTextField.bottomAnchor.constraint(
                equalTo: _inputAccessoryView.layoutMarginsGuide.bottomAnchor,
                constant: -8
            ).isActive = true
        }

        return _inputAccessoryView
    }
    
    @objc func handlePostComment(){
        
        guard let commentToPost = commentTextField.text else {
            
            let alert = UIAlertController(title: "Please fill comment", message: "Empty comments cannot be posted", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        if commentToPost.count == 0 {
            
            let alert = UIAlertController(title: "Please fill comment", message: "Empty comments cannot be posted", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
            return
            
        }
        
        guard let post = self.post else { return }
        guard let email = currentUser?.email else { return }
        
        var commentData = [String:Any]()
        
        commentData["comment"] = commentToPost
        commentData["commentOwner"] = email
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        commentData["timestamp"] = timestamp
        commentData["post"] = "\(post.user.email)-\(post.timestamp)"
        commentData["postOwner"] = post.user.email
        
        db.collection("posts").document("\(post.user.email)-\(post.timestamp)").collection("comments").document("\(post.user.email)-\(post.timestamp)-\(email)-\(timestamp)").setData(commentData) { (err) in
            
                if let err = err {

                    print("couldn't post comment", err)
                    return

                }

                self.commentTextField.text = ""
                self.commentTextField.resignFirstResponder()

                print("comment posted", commentToPost)
                
            self.saveCommentToCommentsCollectionsForBackup(data: commentData, timestamp: timestamp)
            
        }
            

        
        
        
    }
    
    fileprivate func saveCommentToCommentsCollectionsForBackup(data: [String: Any], timestamp: Int64){
        
        guard let post = self.post else { return }
        guard let email = currentUser?.email else { return }
        
        
        db.collection("comments").document("\(post.user.email)-\(post.timestamp)-\(email)-\(timestamp)").setData(data) { (err) in
            
            if let err = err {
                
                print("could not post comment to backup", err)
                return
                
            }
            
            print("successfully posted comment")
            
        }
        
        
    }
    

    override var canBecomeFirstResponder: Bool {
        
        return true
        
    }

}

