//
//  SearchCell.swift
//  Discuss
//
//  Created by Harsh Motwani on 14/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit

class SearchCell: UICollectionViewCell {
    
    
    var user: User? {
        
        didSet{
            
            displayNameLabel.text = user?.displayName ?? "Display Name"
            descriptionLabel.text = user?.description ?? "Description"
            
        }
        
    }
    
    let displayNameLabel: UILabel = {
        
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        label.text = "Display Name"
        return label
        
    }()
    
    let descriptionLabel: UILabel = {
       
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.text = "Description"
        label.textAlignment = .center
        return label
        
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
            
        setupCell()
        
        
    }
    
    fileprivate func setupCell(){
        
        let separatorView = UIView()
        separatorView.backgroundColor = .label
        
        addSubview(displayNameLabel)
        addSubview(descriptionLabel)
        addSubview(separatorView)
        
        displayNameLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
        
            displayNameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
            displayNameLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
            displayNameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            displayNameLabel.heightAnchor.constraint(equalToConstant: 20),
            
            descriptionLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
            descriptionLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
            descriptionLabel.topAnchor.constraint(equalTo: displayNameLabel.bottomAnchor, constant: 5),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 20),
            
            separatorView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            separatorView.leftAnchor.constraint(equalTo: self.leftAnchor),
            separatorView.rightAnchor.constraint(equalTo: self.rightAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    

    
    
}
