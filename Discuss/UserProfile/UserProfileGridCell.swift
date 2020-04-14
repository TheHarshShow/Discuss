//
//  UserProfileGridCell.swift
//  Discuss
//
//  Created by Harsh Motwani on 13/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit

class UserProfileGridCell: UICollectionViewCell {
    
    let titleLabel: UITextView = {
        
        let label = UITextView()
        
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.isEditable = false
        label.isScrollEnabled = false
        label.backgroundColor = .none
        
        return label
        
        
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
        
        addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.backgroundColor = .systemTeal
        
        NSLayoutConstraint.activate([
        
            titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
            titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 14),
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
}
