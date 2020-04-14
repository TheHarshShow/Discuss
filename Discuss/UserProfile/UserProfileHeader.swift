//
//  UserProfileHeader.swift
//  Discuss
//
//  Created by Harsh Motwani on 11/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit
import Firebase

class UserProfileHeader: UICollectionViewCell {
    
    
    let db: Firestore = Firestore.firestore()

    
    let displayNameLabel: UILabel = {
        
        let label = UILabel()
        
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 40)
        return label
        
    }()
    
    let editProfileButton: UIButton = {
        
        let button = UIButton()
        
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.label.cgColor
        button.layer.borderWidth = 1;
        button.layer.cornerRadius = 3
        
        return button
        
    }()
    
    let gridButton: UIButton = {
        
        let button = UIButton(type: .system);
        
        button.setImage(UIImage(named: "grid"), for: .normal)
        
        
        return button
        
        
    }()
    
    let listButton: UIButton = {
        
        let button = UIButton(type: .system);
        
        button.setImage(UIImage(named: "list"), for: .normal)
        button.tintColor = .tertiaryLabel

        
        return button
        
        
    }()
    
    let bookmarkButton: UIButton = {
        
        let button = UIButton(type: .system);
        
        button.setImage(UIImage(named: "ribbon"), for: .normal)
        button.tintColor = .tertiaryLabel

        
        return button
        
        
    }()
    
    
    
    let descriptionTextView: UITextView = {
        
        let tv = UITextView()
        tv.isEditable = false
        tv.isScrollEnabled = true
        tv.textAlignment = .center
        tv.font = UIFont.systemFont(ofSize: 11, weight: UIFont.Weight(rawValue: 2))
        
        return tv;
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .systemBackground
        
        addSubview(displayNameLabel)
        addSubview(descriptionTextView)

        displayNameLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            
            displayNameLabel.topAnchor.constraint(equalTo: self.topAnchor),
            displayNameLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
            displayNameLabel.leftAnchor.constraint(equalTo: self.leftAnchor),
            displayNameLabel.heightAnchor.constraint(equalToConstant: 50),
            
        ])
        
        setupNameLabel()
        
        setupBottomToolBar()
        
    }
    
    fileprivate func setupBottomToolBar(){
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = .label
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = .label
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(editProfileButton)
        editProfileButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        topDividerView.translatesAutoresizingMaskIntoConstraints = false
        bottomDividerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
        
            stackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
            stackView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            stackView.heightAnchor.constraint(equalToConstant: 50),
            
            
            descriptionTextView.topAnchor.constraint(equalTo: self.displayNameLabel.bottomAnchor, constant: 20),
            descriptionTextView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
            descriptionTextView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
            descriptionTextView.bottomAnchor.constraint(equalTo: editProfileButton.topAnchor, constant: -10),
            
            editProfileButton.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -10),
            editProfileButton.widthAnchor.constraint(equalToConstant: 100),
            editProfileButton.heightAnchor.constraint(equalToConstant: 34),
            editProfileButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),

            topDividerView.rightAnchor.constraint(equalTo: self.rightAnchor),
            topDividerView.leftAnchor.constraint(equalTo: self.leftAnchor),
            topDividerView.bottomAnchor.constraint(equalTo: stackView.topAnchor),
            topDividerView.heightAnchor.constraint(equalToConstant: 0.5),
            
            bottomDividerView.rightAnchor.constraint(equalTo: self.rightAnchor),
            bottomDividerView.leftAnchor.constraint(equalTo: self.leftAnchor),
            bottomDividerView.topAnchor.constraint(equalTo: stackView.bottomAnchor),
            bottomDividerView.heightAnchor.constraint(equalToConstant: 0.5),
            
            

        
        
        ])
        
        
    }
    
    func setupNameLabel(){
        
        guard let currentUser = Auth.auth().currentUser else { return }
        guard let email = currentUser.email else { return }
        
        db.collection("users").document(email).addSnapshotListener { (document, err) in
            
            if let err = err{
                
                print("Could not fetch display name", err)
                return
                
            }
            
            guard let docData = document?.data() else { return }
            
            guard let displayName = docData["displayName"] as? String else { return }
            
            self.displayNameLabel.text = displayName
            
            guard let description = docData["description"] as? String else { return }
            
            self.descriptionTextView.text = description
            
        }
        

        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}
