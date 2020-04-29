//
//  CommentPage.swift
//  Discuss
//
//  Created by Harsh Motwani on 28/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit
import Firebase

class CommentPage: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var headerId = "commentHeaderId"
    var cellId = "commentPageCell"
    
    var comment: Comment? {
        
        didSet {
            
            print("COMMENT \(comment!.comment)", comment?.id ?? "")
            fetchComments()
            
        }
        
    }
    

    
    let db = Firestore.firestore()
    
    var comments = [Comment]()
    
    let currentUser = Auth.auth().currentUser
    let commentTextField : UITextField = {
        
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.borderStyle = .roundedRect
        tf.placeholder = "Comment..."
        
        return tf
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(CommentPageHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        
        self.collectionView.backgroundColor = .systemBackground
        
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let commentPage1 = CommentPage(collectionViewLayout: UICollectionViewFlowLayout())
        commentPage1.comment = self.comments[indexPath.item]
        
        navigationController?.pushViewController(commentPage1, animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.tabBar.isHidden = true
        inputAccessoryView?.isHidden = false
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCell
        
        cell.comment = comments[indexPath.item]
        
        return cell
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
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! CommentPageHeader
        
        guard let comment = self.comment else { return header }
        
        print("HEADER COMMENT \(comment.comment)")
        
        header.shouldSnapshotListenerBeSetUp = true
        
        header.comment = comment
//        header.userButton.addTarget(self, action: #selector(handleShowUser), for: .touchUpInside)
        header.commentsCount = comments.count
        header.usernameButton.addTarget(self, action: #selector(handleShowProfile), for: .touchUpInside)
        return header
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        return CGSize(width: view.frame.width, height: 200)
        
        
    }
    
    fileprivate func fetchComments(){
        
        guard let comment = self.comment else { return }
        
        db.collection("comments").whereField("parent", isEqualTo: comment.id).addSnapshotListener { (snapshot, err) in
            
            if let err = err {
                print("could not fetch snapshot", err)
                return
                
            }
            
            guard let documentChanges = snapshot?.documentChanges else { return }
            for dc in documentChanges{
                
                switch dc.type{
                case .added:
                    print("comment added on comment page")
                    let id = dc.document.documentID
                    let docData = dc.document.data()
                    guard let email = docData["commentOwner"] as? String else { return }
                    Firestore.fetchUserWithEmail(email: email) { (user, err) in
                        
                        if err {
                            print("could not fetch user", err)
                            return
                            
                        }
                        guard let user = user else { return }
                        let comment1 = Comment(docData: docData, commentOwner: user, id: id)
                        self.comments.append(comment1)
                        
                        self.comments.sort { (c1, c2) -> Bool in
                            
                            return c1.timestamp >= c2.timestamp
                            
                        }
                        
                        self.collectionView.reloadData()
                    }
                    
                case .modified:
                    print("comment modified on comment page")
                    let id = dc.document.documentID
                    let docData = dc.document.data()
                    guard let email = docData["commentOwner"] as? String else { return }
                    
                    if let index = self.comments.firstIndex(where: { (comment) -> Bool in
                        return comment.id == id
                    }) {
                        
                        Firestore.fetchUserWithEmail(email: email) { (user, err) in
                            
                            if err {
                                print("could not fetch user", err)
                                return
                                
                            }
                            
                            guard let user = user else { return }
                            self.comments[index] = Comment(docData: docData, commentOwner: user, id: id)
                            
                            self.collectionView.reloadData()
                        }
                        
                        
                    }
                
                case .removed:
                    print("comment removed on comment page")
                    
                    print("comment modified on comment page")
                    let id = dc.document.documentID
                    
                    if let index = self.comments.firstIndex(where: { (comment) -> Bool in
                        return comment.id == id
                    }) {
                        
                        self.comments.remove(at: index)
                        
                        self.collectionView.reloadData()
                        
                    }
                    
                default:
                    print("comment changed on comment page")
                }
                
            }
            
        }
        
    }
    
    @objc func handleShowProfile(){
        
        guard let email = comment?.commentOwner.email else { return }
        guard let user = comment?.commentOwner else { return }
        
        let userProfileViewController = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileViewController.userEmail = email
        userProfileViewController.user = user
        
        navigationController?.pushViewController(userProfileViewController, animated: true)
    }
 
    override var canBecomeFirstResponder: Bool {
        
        return true
        
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
        
        if commentTextField.text?.count ?? 0 == 0 {
            
            let alert = UIAlertController(title: "No comment to post!", message: "Please fill in the comment field", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        self.commentTextField.resignFirstResponder()
        
        guard let parent = self.comment else { return }
        guard let email = currentUser?.email else { return }
        guard let comment = commentTextField.text else { return }
        var dictToPost = [String: Any]()
        
        dictToPost["comment"] = comment
        dictToPost["parent"] = parent.id
        dictToPost["commentOwner"] = email
        dictToPost["parentOwner"] = parent.commentOwner.email
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        dictToPost["timestamp"] = timestamp
        
        
        
        db.collection("comments").document("\(parent.id)-\(email)-\(timestamp)").setData(dictToPost) { (err) in
            
            if let err = err {
                print("could not post comment", err)
                return
            }
            self.commentTextField.text = ""
            
        }
        
    }
    
    
}
