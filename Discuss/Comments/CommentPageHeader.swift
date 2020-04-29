//
//  CommentPageHeader.swift
//  Discuss
//
//  Created by Harsh Motwani on 28/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit
import Firebase

class CommentPageHeader: UICollectionViewCell {
    
    let currentUser = Auth.auth().currentUser
    
    let db = Firestore.firestore()
    
    let likeCountLabel: UILabel = {
        
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.text = "0"
        return label
        
    }()
    
    
    var shouldSnapshotListenerBeSetUp: Bool?
    
    var comment: Comment? {
        
        didSet{
            
            guard let email = currentUser?.email else { return }
            
            print("Comment on header: ", comment?.comment ?? "")
            commentTextView.text = comment?.comment ?? ""
            usernameButton.setTitle(comment?.commentOwner.displayName ?? "", for: .normal)
            
            if comment?.liked.contains(email) ?? false {
                
                likeButton.setImage(UIImage(named: "heart_selected"), for: .normal)
                
            } else {

                likeButton.setImage(UIImage(named: "heart_unselected"), for: .normal)
                
            }
            
            if shouldSnapshotListenerBeSetUp ?? true{
            
                setupLikeSnapshotListener()
            }
            
            likeCountLabel.text = "\(comment?.liked.count ?? 0)"
            
        }
        
    }
    
    let commentsLabel: UILabel = {
        
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "Comments: ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)])
        
        label.attributedText = attributedText
        return label
        
    }()
    
    var commentsCount: Int? {
        
        didSet {
            
            let attributedText = NSMutableAttributedString(string: "Comments: ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)])
            let attributedString = NSAttributedString(string: "\(commentsCount ?? 0)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20)])
            attributedText.append(attributedString)
            commentsLabel.attributedText = attributedText
            
        }
        
    }
    
    let likeButton: UIButton = {
        
        let button = UIButton()
        button.tintColor = .label
        button.imageView?.contentMode = .scaleAspectFit
        return button
        
    }()
    
    let commentTextView: UITextView = {
        
        let tv = UITextView()
        tv.isEditable = false
        tv.textAlignment = .center
        tv.backgroundColor = .none
        tv.textColor = .label
        tv.font = UIFont.systemFont(ofSize: 15)
        tv.isScrollEnabled = true
        return tv
        
    }()
    
    let usernameButton: UIButton = {
        
        let button = UIButton()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.label, for: .normal)
        return button
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        setupViews()
        likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews(){
        
        let firstSeparatorView = UIView()
        firstSeparatorView.backgroundColor = .label
        
        let secondSeparatorView = UIView()
        secondSeparatorView.backgroundColor = .label
        
        addSubview(commentTextView)
        addSubview(usernameButton)
        addSubview(firstSeparatorView)
        addSubview(likeButton)
        addSubview(secondSeparatorView)
        addSubview(likeCountLabel)
        addSubview(commentsLabel)
        
        commentsLabel.translatesAutoresizingMaskIntoConstraints = false
        secondSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        firstSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        usernameButton.translatesAutoresizingMaskIntoConstraints = false
        commentTextView.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            likeCountLabel.leftAnchor.constraint(equalTo: likeButton.rightAnchor, constant: 10),
            likeCountLabel.topAnchor.constraint(equalTo: likeButton.topAnchor),
            likeCountLabel.bottomAnchor.constraint(equalTo: likeButton.bottomAnchor),
            likeCountLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
            
            usernameButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 30),
            usernameButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
            usernameButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
            usernameButton.heightAnchor.constraint(equalToConstant: 14),
            
            firstSeparatorView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            firstSeparatorView.leftAnchor.constraint(equalTo: self.leftAnchor),
            firstSeparatorView.rightAnchor.constraint(equalTo: self.rightAnchor),
            firstSeparatorView.heightAnchor.constraint(equalToConstant: 1),
            
            commentTextView.topAnchor.constraint(equalTo: usernameButton.bottomAnchor, constant: 10),
            commentTextView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
            commentTextView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
            commentTextView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -25),
            
            secondSeparatorView.leftAnchor.constraint(equalTo: self.leftAnchor),
            secondSeparatorView.rightAnchor.constraint(equalTo: self.rightAnchor),
            secondSeparatorView.bottomAnchor.constraint(equalTo: commentTextView.bottomAnchor),
            secondSeparatorView.heightAnchor.constraint(equalToConstant: 1),
            
            likeButton.bottomAnchor.constraint(equalTo: firstSeparatorView.topAnchor, constant: -3),
            likeButton.leftAnchor.constraint(equalTo: self.centerXAnchor, constant: 10),
            likeButton.widthAnchor.constraint(equalToConstant: 25),
            likeButton.topAnchor.constraint(equalTo: secondSeparatorView.bottomAnchor, constant: 3),
            
            commentsLabel.bottomAnchor.constraint(equalTo: firstSeparatorView.topAnchor, constant: -3),
            commentsLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
            commentsLabel.rightAnchor.constraint(equalTo: self.centerXAnchor),
            commentsLabel.topAnchor.constraint(equalTo: secondSeparatorView.bottomAnchor, constant: 3),
            
        ])
        
    }
    
    @objc fileprivate func handleLike(){
        
        guard let comment = self.comment else { return }
        Firestore.registerLikeForComment(comment: comment)
        
    }
    
    fileprivate func setupLikeSnapshotListener(){
        
        guard let comment = self.comment else { return }
        
        db.collection("comments").document(comment.id).addSnapshotListener { (document, err) in
            
            if let err = err {
                print("could not fetch change", err)
                return
            }
            
            guard let docData = document?.data() else { return }
            guard let id = document?.documentID else { return }
            self.shouldSnapshotListenerBeSetUp = false
            let comment = Comment(docData: docData, commentOwner: comment.commentOwner, id: id)
            self.comment = comment
        }
    }
}
