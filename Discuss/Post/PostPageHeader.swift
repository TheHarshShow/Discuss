//
//  PostPageHeader.swift
//  Discuss
//
//  Created by Harsh Motwani on 16/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit
import Firebase

class PostPageHeader: UICollectionViewCell {
    
    let db = Firestore.firestore()
    
    let currentUser = Auth.auth().currentUser
    
    let likeButton: UIButton = {
    
        let button = UIButton(type: .system)
        button.tintColor = .label
        button.setImage(UIImage(named: "like_unselected"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    
    }()
    
    let bookmarkButton: UIButton = {
    
        let button = UIButton(type: .system)
        button.tintColor = .label
        button.setImage(UIImage(named: "ribbon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit

        return button
    
    }()
    
    let titleLabel: UILabel = {
        
        let label = UILabel()
        
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        label.backgroundColor = .systemTeal
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        return label
        
    }()
    
    let descriptionTextView: UITextView = {
        
        let tv = UITextView()
        
        tv.isEditable = false
        tv.isScrollEnabled = true
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.backgroundColor = .none
        tv.textAlignment = .center
        tv.layer.borderWidth = 0.5
        tv.layer.borderColor = UIColor.label.cgColor
        return tv
        
    }()
    
    let userButton: UIButton = {
        
        let button = UIButton()
        button.setTitle("User", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        return button
        
    }()
    
    var post: Post? {
            
        didSet{
            
            userButton.setTitle(post?.user.displayName ?? "Username not available", for: .normal)
            titleLabel.text = post?.postTitle ?? ""
            descriptionTextView.text = post?.description ?? ""
                
            guard let email = currentUser?.email else { return }
            
            if self.post?.liked.contains(email) ?? false {
                
                print("like observed")
                self.likeButton.setImage(UIImage(named: "like_selected"), for: .normal)
                
            } else {
                
                print("unlike observed")
                self.likeButton.setImage(UIImage(named: "like_unselected"), for: .normal)
                
            }
            
            if self.post?.bookmarked.contains(email) ?? false {
                
                self.bookmarkButton.setImage(UIImage(named: "tick"), for: .normal)
                
            } else {
                
                self.bookmarkButton.setImage(UIImage(named: "ribbon"), for: .normal)
                
            }
            
            
        }

    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemBackground
        
        setupViews()
        setupLikeButton()
        
    }
    
    fileprivate func setupLikeButton(){
        
        likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        bookmarkButton.addTarget(self, action: #selector(handleBookmark), for: .touchUpInside)
        
    }
    
    
    
    fileprivate func setupViews(){
        
        let separatorView = UIView()
        separatorView.backgroundColor = .label
        
        let topSeparatorView = UIView()
        topSeparatorView.backgroundColor = .label
        
        let stackView = UIStackView(arrangedSubviews: [likeButton, bookmarkButton])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        
        addSubview(titleLabel)
        addSubview(descriptionTextView)
        addSubview(userButton)
        addSubview(separatorView)
        addSubview(stackView)
        addSubview(topSeparatorView)
        
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        userButton.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        topSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            userButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 30),
            userButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
            userButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
            userButton.heightAnchor.constraint(equalToConstant: 14),
            
            titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: userButton.bottomAnchor, constant: 10),
            titleLabel.heightAnchor.constraint(equalToConstant: self.frame.height-105),
            titleLabel.widthAnchor.constraint(equalToConstant: self.frame.height-105),
            
            descriptionTextView.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 10),
            descriptionTextView.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            descriptionTextView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            descriptionTextView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
            
            stackView.rightAnchor.constraint(equalTo: self.rightAnchor),
            stackView.leftAnchor.constraint(equalTo: self.leftAnchor),
            stackView.bottomAnchor.constraint(equalTo: separatorView.topAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 40),
            
            separatorView.rightAnchor.constraint(equalTo: self.rightAnchor),
            separatorView.leftAnchor.constraint(equalTo: self.leftAnchor),
            separatorView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            
            topSeparatorView.rightAnchor.constraint(equalTo: self.rightAnchor),
            topSeparatorView.leftAnchor.constraint(equalTo: self.leftAnchor),
            topSeparatorView.bottomAnchor.constraint(equalTo: stackView.topAnchor),
            topSeparatorView.heightAnchor.constraint(equalToConstant: 0.5),
        
        ])
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func handleLike(){
        
        guard let post = self.post else { return }
        
        Firestore.registerLikeForPost(post: post)
        
        guard let email = currentUser?.email else { return }

        if post.liked.contains(email){
            
            self.likeButton.setImage(UIImage(named: "like_unselected"), for: .normal)
            
        } else {
            
            self.likeButton.setImage(UIImage(named: "like_selected"), for: .normal)
            
        }
        
    }
    
    @objc func handleBookmark(){
        
        guard let post = self.post else { return }
        
        Firestore.registerBookmarkForPost(post: post)
        
        guard let email = currentUser?.email else { return }
        
        if post.bookmarked.contains(email){
                   
           self.bookmarkButton.setImage(UIImage(named: "ribbon"), for: .normal)
           
       } else {
           
           self.bookmarkButton.setImage(UIImage(named: "tick"), for: .normal)
           
       }
        
    }
    
}
