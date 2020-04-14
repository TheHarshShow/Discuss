//
//  HomePageCell.swift
//  Discuss
//
//  Created by Harsh Motwani on 14/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit

class HomePageCell: UICollectionViewCell {
    
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
        
        let button = UIButton()
        button.setImage(UIImage(named: "ribbon"), for: .normal)
        button.tintColor = .label
        button.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
        
        return button
        
    }()
    
    var post: Post? {
        
        didSet{
            
            print(post?.user.email ?? "")
            
            let postTitle = post?.postTitle ?? ""
            
            self.titleLabel.text = postTitle
            
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        
        setupViews()
        
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
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
}
