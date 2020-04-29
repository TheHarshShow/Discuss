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
        
    var comments: [Comment] = []
    
    let headerId = "postPageHeader"
    
    let db = Firestore.firestore()
    
    let cellId = "PostPageCellId"
    
    let currentUser = Auth.auth().currentUser
    
    let commentTextField : UITextField = {
        
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.borderStyle = .roundedRect
        tf.placeholder = "Comment..."
        
        return tf
        
    }()
    
    
    var post: Post?
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.width
        
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]

        dummyCell.layoutIfNeeded()

        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        return CGSize(width: width , height: estimatedSize.height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCell
        
        cell.comment = comments[indexPath.item]
        
        return cell
    }
    

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! PostPageHeader
        
        guard let post = self.post else { return header }
        
        header.post = post
        header.userButton.addTarget(self, action: #selector(handleShowUser), for: .touchUpInside)
        header.commentsCount = comments.count
        
        return header
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 280)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let commentPage = CommentPage(collectionViewLayout: UICollectionViewFlowLayout())
        commentPage.comment = comments[indexPath.row]
        
        navigationController?.pushViewController(commentPage, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Post"
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        
        collectionView.register(PostPageHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView.keyboardDismissMode = .interactive
        
        fetchComments()
        setupPostForHeader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.tabBar.isHidden = true
        inputAccessoryView?.isHidden = false
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = false
        self.view.endEditing(true)
        inputAccessoryView?.isHidden = true
        
    }
    
    fileprivate func setupPostForHeader(){
        
        guard let post = self.post else { return }
        
        db.collection("posts").document("\(post.user.email)-\(post.timestamp)").addSnapshotListener { (document, err) in
            
            if let err = err {
                
                print("could not get snapshot", err)
                return
                
            }
            
            guard let docData = document?.data() else { return }
            guard let email = docData["userEmail"] as? String else { return }
            
            Firestore.fetchUserWithEmail(email: email) { (user, err) in
                
                if err {
                    print("could not get user")
                    return
                }
                
                guard let user = user else { return }
                
                self.post = Post(docData: docData, user: user)
                
                print("post changed!")
                self.collectionView.reloadData()
                
            }
            
        }
        
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
        self.commentTextField.resignFirstResponder()
        self.saveCommentToCommentsCollectionsForBackup(data: commentData, timestamp: timestamp)
        
        
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
            self.commentTextField.text = ""
            
        }
        
        
    }
    

    override var canBecomeFirstResponder: Bool {
        
        return true
        
    }
    
    fileprivate func fetchComments(){
        
        guard let post = self.post else { return }
        
        db.collection("comments").whereField("post", isEqualTo: "\(post.user.email)-\(post.timestamp)").addSnapshotListener { (snapshot, err) in
            
            if let err = err {
                  
                  print("could not get comment snapshot", err)
                  return
                  
              }
              
              guard let documentChanges = snapshot?.documentChanges else { return }
              
              for dc in documentChanges{
                  
                  switch dc.type {
                  case .added:
                      
                      let docData = dc.document.data()
                      
                      guard let commentOwner = docData["commentOwner"] as? String else { return }
                      
                      Firestore.fetchUserWithEmail(email: commentOwner) { (user, err) in
                          
                          
                          if err {
                              
                              print("could not fetch comment owner")
                              return
                              
                          }
                          
                          guard let user = user else { return }
                          
                        let comment = Comment(docData: docData, commentOwner: user, id: dc.document.documentID)
                         self.comments.append(comment)
                         
                         self.comments.sort { (c1, c2) -> Bool in
                             return c1.timestamp >= c2.timestamp
                         }
                         
                         self.collectionView.reloadData()
                          
                      }
                      
            
                     
                      
                  case .modified:
                      print("comment modified")
                      
                      let docData = dc.document.data()
                      guard let commentOwner = docData["commentOwner"] as? String else { return }
                      
                      Firestore.fetchUserWithEmail(email: commentOwner) { (user, err) in
                          
                          
                          if err {
                              
                              print("could not fetch comment owner")
                              return
                              
                          }
                          
                          guard let user = user else { return }
                          
                        let comment = Comment(docData: docData, commentOwner: user, id: dc.document.documentID)
                         
                         
                          if let index = self.comments.firstIndex(where: { (commentt) -> Bool in
                              return commentt.timestamp == comment.timestamp
                              
                          }){
                              
                              self.comments[index] = comment
                              
                          }
                         
                          
                         
                         self.collectionView.reloadData()
                          
                      }
                      
                      
                  case .removed:
                      print("comment removed")
                      let docData = dc.document.data()
                      guard let commentOwner = docData["commentOwner"] as? String else { return }
                      
                      Firestore.fetchUserWithEmail(email: commentOwner) { (user, err) in
                          
                          
                          if err {
                              
                              print("could not fetch comment owner")
                              return
                              
                          }
                          
                          guard let user = user else { return }
                          
                        let comment = Comment(docData: docData, commentOwner: user, id: dc.document.documentID)
                         if let index = self.comments.firstIndex(where: { (commentt) -> Bool in
                             return commentt.timestamp == comment.timestamp
                             
                         }){
                             
                          self.comments.remove(at: index)
                             
                         }
                         
                         self.collectionView.reloadData()
                          
                      }
                  default:
                      print("comment changed")
                  }
                  
              }
            
        }
        
//        db.collection("posts").document("\(post.user.email)-\(post.timestamp)").collection("comments").addSnapshotListener { (snapshot, err) in
//            
//            if let err = err {
//                
//                print("could not get comment snapshot", err)
//                return
//                
//            }
//            
//            guard let documentChanges = snapshot?.documentChanges else { return }
//            
//            for dc in documentChanges{
//                
//                switch dc.type {
//                case .added:
//                    
//                    let docData = dc.document.data()
//                    guard let commentOwner = docData["commentOwner"] as? String else { return }
//                    
//                    Firestore.fetchUserWithEmail(email: commentOwner) { (user, err) in
//                        
//                        
//                        if err {
//                            
//                            print("could not fetch comment owner")
//                            return
//                            
//                        }
//                        
//                        guard let user = user else { return }
//                        
//                        let comment = Comment(docData: docData, commentOwner: user)
//                       self.comments.append(comment)
//                       
//                       self.comments.sort { (c1, c2) -> Bool in
//                           return c1.timestamp >= c2.timestamp
//                       }
//                       
//                       self.collectionView.reloadData()
//                        
//                    }
//                    
//          
//                   
//                    
//                case .modified:
//                    print("comment modified")
//                    
//                    let docData = dc.document.data()
//                    guard let commentOwner = docData["commentOwner"] as? String else { return }
//                    
//                    Firestore.fetchUserWithEmail(email: commentOwner) { (user, err) in
//                        
//                        
//                        if err {
//                            
//                            print("could not fetch comment owner")
//                            return
//                            
//                        }
//                        
//                        guard let user = user else { return }
//                        
//                        let comment = Comment(docData: docData, commentOwner: user)
//                       
//                       
//                        if let index = self.comments.firstIndex(where: { (commentt) -> Bool in
//                            return commentt.timestamp == comment.timestamp
//                            
//                        }){
//                            
//                            self.comments[index] = comment
//                            
//                        }
//                       
//                        
//                       
//                       self.collectionView.reloadData()
//                        
//                    }
//                    
//                    
//                case .removed:
//                    print("comment removed")
//                    let docData = dc.document.data()
//                    guard let commentOwner = docData["commentOwner"] as? String else { return }
//                    
//                    Firestore.fetchUserWithEmail(email: commentOwner) { (user, err) in
//                        
//                        
//                        if err {
//                            
//                            print("could not fetch comment owner")
//                            return
//                            
//                        }
//                        
//                        guard let user = user else { return }
//                        
//                        let comment = Comment(docData: docData, commentOwner: user)
//                       if let index = self.comments.firstIndex(where: { (commentt) -> Bool in
//                           return commentt.timestamp == comment.timestamp
//                           
//                       }){
//                           
//                        self.comments.remove(at: index)
//                           
//                       }
//                       
//                       self.collectionView.reloadData()
//                        
//                    }
//                default:
//                    print("comment changed")
//                }
//                
//            }
//            
//            
//        }
        
        
    }
    

}

