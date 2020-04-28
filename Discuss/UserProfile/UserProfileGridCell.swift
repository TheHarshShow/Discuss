//
//  UserProfileGridCell.swift
//  Discuss
//
//  Created by Harsh Motwani on 13/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit

class UserProfileGridCell: UICollectionViewCell {
    
    let backgroundImageView: CustomImageView = {
        
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
        
    }()
    
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
            
            let postTitle = post?.postTitle ?? ""
            
            self.titleLabel.text = postTitle
            
            self.backgroundImageView.image = nil
            self.backgroundImageView.loadImageFromUrl(imageUrl: post?.imageUrl ?? "")
            
            if let color = self.post?.color {
                if color != "" {
                    self.titleLabel.textColor = colorDict[color]
                } else {
                    self.titleLabel.textColor = .label
                }
            }
            if let font = self.post?.font {
                if font == "" {
                    self.titleLabel.font = UIFont.boldSystemFont(ofSize: 13)
                } else {
                    self.titleLabel.font = UIFont(name: font, size: 14)
                }
            }
            
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(backgroundImageView)
        addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.backgroundColor = .systemTeal
        
        NSLayoutConstraint.activate([
            
            backgroundImageView.leftAnchor.constraint(equalTo: self.leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: self.rightAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
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
