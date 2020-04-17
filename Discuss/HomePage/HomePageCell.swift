//
//  HomePageCell.swift
//  Discuss
//
//  Created by Harsh Motwani on 14/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit
import Firebase

protocol HomePageCellDelegate {
    func didTapLike(post: Post)
    
}

var postListenCache: [ListenerRegistration] = []

class HomePageCell: UICollectionViewCell {
    
    var delegate: HomePageCellDelegate?
    
    let db = Firestore.firestore()
    
    let currentUser = Auth.auth().currentUser
    
    let titleLabel: UITextView = {
        
        let label = UITextView()
        
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.isEditable = false
        label.isScrollEnabled = false
        label.backgroundColor = .none
        
        return label
        
        
    }()
    
    let optionsButton: UIButton = {
        
        let button = UIButton(type: .system)
        
        button.setTitle("•••", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
        return button
        
    }()
    
    let likeButton: UIButton = {
        
        let button = UIButton(type: .system)
        
        button.setImage(UIImage(named: "like_unselected"), for: .normal)
        button.tintColor = .label
        button.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
        
        return button
        
    }()
    
    let bookmarkButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "ribbon"), for: .normal)
        button.tintColor = .label
        button.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
        
        return button
        
    }()

    var snapshotListenerNotSetUp: Bool?
    
    var post: Post? {
        
        didSet{
            
            print(self.post?.user.email ?? "")
            
            let postTitle = self.post?.postTitle ?? ""
            
            self.titleLabel.text = postTitle
            
            guard let email = currentUser?.email else { return }
            
            if self.post?.liked.contains(email) ?? false {
                
                likeButton.setImage(UIImage(named: "like_selected"), for: .normal)
                
            } else {
                
                likeButton.setImage(UIImage(named: "like_unselected"), for: .normal)
                
            }
            
            if snapshotListenerNotSetUp ?? true {
                
                addSnapshotListener()
                
            }
            
            
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        
    }
    
    fileprivate func setupViews(){

        optionsButton.layer.cornerRadius = 15.0/2
        optionsButton.clipsToBounds = true
        
        likeButton.layer.cornerRadius = 15.0/2
        likeButton.clipsToBounds = true
        
        bookmarkButton.layer.cornerRadius = 15.0/2
        bookmarkButton.clipsToBounds = true
        
        addSubview(titleLabel)
        addSubview(likeButton)
        addSubview(optionsButton)
        addSubview(bookmarkButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        optionsButton.translatesAutoresizingMaskIntoConstraints = false
        bookmarkButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.backgroundColor = .systemTeal
        
        NSLayoutConstraint.activate([
        
            titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
            titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 14),
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            optionsButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
            optionsButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            optionsButton.heightAnchor.constraint(equalToConstant: 15),
            optionsButton.widthAnchor.constraint(equalToConstant: 30),
            
            likeButton.topAnchor.constraint(equalTo: self.optionsButton.bottomAnchor, constant: 10),
            likeButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
            likeButton.widthAnchor.constraint(equalToConstant: 30),
            likeButton.heightAnchor.constraint(equalToConstant: 30),
            
            bookmarkButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
            bookmarkButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 30),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 30),
        
        ])
        
        
    }
    
    @objc func likeButtonTapped(){
        
        guard let post = self.post else { return }
        delegate?.didTapLike(post: post)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    fileprivate func addSnapshotListener(){
        
        guard let post = self.post else { return }
        
        let snapshotListener =  db.collection("posts").document("\(post.user.email)-\(post.timestamp)").addSnapshotListener { (document, err) in
            
            if let err = err {
                
                print("could not get snapshot", err)
                return
                
            }
            
            self.snapshotListenerNotSetUp = false
            
            guard let docData = document?.data() else { return }
            
            let postt = Post(docData: docData, user: post.user)
            
            if postt.user.email == self.post?.user.email && postt.timestamp == self.post?.timestamp {
                
                self.post = postt
                
            }
            
        }
        
        postListenCache.append(snapshotListener)
        
    }
    
    
}
