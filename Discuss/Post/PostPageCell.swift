//
//  PostPageCell.swift
//  Discuss
//
//  Created by Harsh Motwani on 17/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit
import Firebase

class PostPageCell: UICollectionViewCell {
    
    var comment: Comment? {
        
        didSet {
            
            guard let commentOwner = comment?.commentOwner.displayName else { return }
            guard let comment = comment?.comment else { return }
            
            let attributedText = NSMutableAttributedString(string: commentOwner+" ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.label])
            
            
            
            attributedText.append(NSAttributedString(string: comment, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.label]))
            
            commentTextView.attributedText = attributedText
            
        }
        
    }
    

    
    let commentTextView: UITextView = {
        
        let tv = UITextView()
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.textColor = .label
        tv.backgroundColor = .none
        
        
        return tv
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        backgroundColor = .systemRed
        
        
        setupViews()
        
        
        
    }
    
    fileprivate func setupViews(){
        
        addSubview(commentTextView)
        
        commentTextView.translatesAutoresizingMaskIntoConstraints = false
        
        let separatorView = UIView()
        addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = .label
        
        NSLayoutConstraint.activate([
        
            commentTextView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5),
            commentTextView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5),
            commentTextView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            commentTextView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            
            separatorView.rightAnchor.constraint(equalTo: self.rightAnchor),
            separatorView.leftAnchor.constraint(equalTo: self.leftAnchor),
            separatorView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
        
        ])
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
