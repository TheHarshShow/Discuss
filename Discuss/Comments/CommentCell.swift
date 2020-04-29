//
//  PostPageCell.swift
//  Discuss
//
//  Created by Harsh Motwani on 17/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit
import Firebase

class CommentCell: UICollectionViewCell {
    
    let likeImage: UIImageView = {
        
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "heart_selected")
        
        return iv
        
    }()
        
    let likeCountLabel: UILabel = {
        
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.text = "0"
        return label
        
    }()
    
    var comment: Comment? {
        
        didSet {
            
            guard let commentOwner = comment?.commentOwner.displayName else { return }
            guard let comment = comment?.comment else { return }
            
            let attributedText = NSMutableAttributedString(string: commentOwner+" ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.label])
            
            attributedText.append(NSAttributedString(string: comment, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.label]))
            
            commentTextView.attributedText = attributedText
            likeCountLabel.text = "\(self.comment?.liked.count ?? 0)"
            
        }
        
    }
    

    
    let commentTextView: UITextView = {
        
        let tv = UITextView()
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.textColor = .label
        tv.backgroundColor = .none
        tv.isUserInteractionEnabled = false
        
        return tv
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        backgroundColor = .systemRed
        
        
        setupViews()
        
        
        
    }
    
    fileprivate func setupViews(){
        
        addSubview(commentTextView)
        addSubview(likeImage)
        addSubview(likeCountLabel)
        
        commentTextView.translatesAutoresizingMaskIntoConstraints = false
        likeImage.translatesAutoresizingMaskIntoConstraints = false
        likeCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let separatorView = UIView()
        addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = .label
        
        NSLayoutConstraint.activate([
        
            commentTextView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5),
            commentTextView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5),
            commentTextView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -14),
            commentTextView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            
            likeImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
            likeImage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4),
            likeImage.widthAnchor.constraint(equalToConstant: 10),
            likeImage.heightAnchor.constraint(equalToConstant: 10),
            
            separatorView.rightAnchor.constraint(equalTo: self.rightAnchor),
            separatorView.leftAnchor.constraint(equalTo: self.leftAnchor),
            separatorView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            
            likeCountLabel.leftAnchor.constraint(equalTo: likeImage.rightAnchor, constant: 5),
            likeCountLabel.bottomAnchor.constraint(equalTo: likeImage.bottomAnchor),
            likeCountLabel.topAnchor.constraint(equalTo: likeImage.topAnchor),
            likeCountLabel.rightAnchor.constraint(equalTo: self.centerXAnchor),
        
        ])
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
