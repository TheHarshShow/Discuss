//
//  UserProfileHeader.swift
//  Discuss
//
//  Created by Harsh Motwani on 11/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit
import Firebase

protocol UserProfileHeaderDelegate {
    
    func didChangeToListView()
    func didChangeToGridView()
    func didChangetoBookmarkView()
    func handleEditProfile()
    func goToFollowingPage(user: User)
}

class UserProfileHeader: UICollectionViewCell {
    
    var user: User? {
        
        didSet {
            
            self.displayNameLabel.text = user?.displayName ?? ""
            self.descriptionTextView.text = user?.description ?? ""
            self.backgroundImageView.loadImageFromUrl(imageUrl: user?.profilePictureUrl ?? "")
            setupEditProfileButton()
            setupFollowingCount()
            
            
        }
        
        
    }
    
    let backgroundImageView: CustomImageView = {
        
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.alpha = 0.3
        return iv
        
    }()
    
    let followingLabel: UIButton = {
        
        let label = UIButton()
        let attributedText = NSMutableAttributedString(string: "following: ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : UIColor.label])
        
        label.setAttributedTitle(attributedText, for: .normal)
        
        return label
        
    }()

    
    var delegate: UserProfileHeaderDelegate?
    
    let db: Firestore = Firestore.firestore()

    
    let displayNameLabel: UILabel = {
        
        let label = UILabel()
        
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 40)
        return label
        
    }()
    
    let editProfileFollowButton: UIButton = {
        
        let button = UIButton()
        
//        button.setTitle("Edit Profile", for: .normal)
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
    
    let grid2Button: UIButton = {
        
        let button = UIButton(type: .system);
        
        button.setImage(UIImage(named: "grid2_selected"), for: .normal)
        button.tintColor = .tertiaryLabel

        
        return button
        
        
    }()
    
    let bookmarkButton: UIButton = {
        
        let button = UIButton(type: .system);
        
        button.setImage(UIImage(named: "tick"), for: .normal)
        button.tintColor = .tertiaryLabel

        
        return button
        
        
    }()
    
    
    
    let descriptionTextView: UILabel = {
        
        let tv = UILabel()
//        tv.isEditable = false
//        tv.isScrollEnabled = true
        tv.textAlignment = .center
        tv.adjustsFontSizeToFitWidth = true
        tv.font = UIFont.systemFont(ofSize: 11, weight: UIFont.Weight(rawValue: 2))
        
        return tv;
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .systemBackground
        
        let attributedString = NSMutableAttributedString(string: "following: ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)])
        attributedString.append(NSAttributedString(string: "0", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15)]))
        self.followingLabel.setAttributedTitle(attributedString, for: .normal)
        
        addSubview(backgroundImageView)
        addSubview(displayNameLabel)
        addSubview(descriptionTextView)
        
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        grid2Button.addTarget(self, action: #selector(handleList), for: .touchUpInside)
        gridButton.addTarget(self, action: #selector(handleGrid), for: .touchUpInside)
        bookmarkButton.addTarget(self, action: #selector(handleBookmarkMove), for: .touchUpInside)
        followingLabel.addTarget(self, action: #selector(followingCountTapped), for: .touchUpInside)
        
        displayNameLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            displayNameLabel.topAnchor.constraint(equalTo: self.topAnchor),
            displayNameLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
            displayNameLabel.leftAnchor.constraint(equalTo: self.leftAnchor),
            displayNameLabel.heightAnchor.constraint(equalToConstant: 50),
            
            backgroundImageView.leftAnchor.constraint(equalTo: self.leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: self.rightAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
        setupBottomToolBar()
//        setupEditProfileButton()
    }
    
    
    
    @objc fileprivate func handleList(){
        
        grid2Button.tintColor = .systemBlue
        gridButton.tintColor = .tertiaryLabel
        bookmarkButton.tintColor = .tertiaryLabel
        delegate?.didChangeToListView()
        
    }
    
    @objc fileprivate func handleGrid(){
        
        grid2Button.tintColor = .tertiaryLabel
        gridButton.tintColor = .systemBlue
        bookmarkButton.tintColor = .tertiaryLabel
        delegate?.didChangeToGridView()
    }
    
    @objc fileprivate func handleBookmarkMove(){
        
        grid2Button.tintColor = .tertiaryLabel
        gridButton.tintColor = .tertiaryLabel
        bookmarkButton.tintColor = .systemBlue
        delegate?.didChangetoBookmarkView()
        
    }
    
    fileprivate func setupEditProfileButton(){
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        guard let userEmail = user?.email else {
            editProfileFollowButton.setTitle("Edit Profile", for: .normal)
            return
        }
        
        if currentUser.email == userEmail {
            editProfileFollowButton.setTitle("Edit Profile", for: .normal)
        } else {
            print("EMAILLLY", userEmail)
            setupFollowButton()
        }
        
        editProfileFollowButton.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)
        
    }
    
    fileprivate func setupFollowingCount(){
        
        
        
        guard let email = self.user?.email ?? Auth.auth().currentUser?.email else { return }
        
        db.collection("following").document(email).addSnapshotListener { (document, err) in
            
            if let err = err {
                
                print("could not get following snapshot", err)
                return
                
            }
            
            guard let document = document else { return }
            
            if document.exists {
                
                guard let docData = document.data() else { return }
                guard let folVal = Array(docData.values) as? [Bool] else { return }
                let folCount = folVal.filter({ (bool) -> Bool in
                    return bool == true
                    }).count
                let attributedString = NSMutableAttributedString(string: "following: ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)])
                attributedString.append(NSAttributedString(string: "\(folCount)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15)]))
                self.followingLabel.setAttributedTitle(attributedString, for: .normal)

                
            } else {
            
                let attributedString = NSMutableAttributedString(string: "following: ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)])
                attributedString.append(NSAttributedString(string: "0", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15)]))
                self.followingLabel.setAttributedTitle(attributedString, for: .normal)
            }
            
            
        }
        
        
    }
    
    fileprivate func setupFollowButton(){
        
        
        guard let userEmail = user?.email else { return }
        guard let currentUserEmail = Auth.auth().currentUser?.email else { return }
        
        db.collection("following").document(currentUserEmail).addSnapshotListener { (document, err) in
            
            if let err = err {
                
                print("couldn't get snapshot", err)
                return
                
            }
            
            guard let docData = document?.data() else {
                
                self.editProfileFollowButton.setTitle("Follow", for: .normal)
                self.editProfileFollowButton.setTitleColor(.systemBackground, for: .normal)
                self.editProfileFollowButton.backgroundColor = .systemGreen
                
                return
                
            }
            
            if docData[userEmail] == nil || (docData[userEmail] as? Bool ?? false) == false {
                
                self.editProfileFollowButton.setTitle("Follow", for: .normal)
                self.editProfileFollowButton.setTitleColor(.systemBackground, for: .normal)
                self.editProfileFollowButton.backgroundColor = .systemGreen
                
            } else {
                
                self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                self.editProfileFollowButton.setTitleColor(.systemBackground, for: .normal)
                self.editProfileFollowButton.backgroundColor = .systemRed
            }
            
        }
        
        
    }
    
    
    @objc fileprivate func handleEditProfileOrFollow(){
        
        
        guard let email = Auth.auth().currentUser?.email else { return }
        
        guard let email2 = user?.email else {
            
            delegate?.handleEditProfile()
            
            return
        }
        
        if email != email2 {
            
            //Follow
            print("\(email) following \(email2)")
            
            if(editProfileFollowButton.titleLabel?.text ?? "" == "Follow"){
                
                db.collection("following").document(email).setData([email2: true], merge: true) { (err) in
                    
                    if let err = err {
                        
                        print("error following", err)
                        return
                        
                    }
                    
                    print("successfully followed")
                    
                    
                }
                
            } else {
                
                db.collection("following").document(email).setData([email2: false], merge: true) { (err) in
                                   
                   if let err = err {
                       
                       print("error unfollowing", err)
                       return
                       
                   }
                   
                   print("successfully unfollowed")
                   
               }
               
                
                
            }

            
            
        } else {
            //Edit profile
            delegate?.handleEditProfile()
        }
        
    }
    
    fileprivate func setupBottomToolBar(){
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, grid2Button, bookmarkButton])
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = .label
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = .label
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(editProfileFollowButton)
        addSubview(followingLabel)
        editProfileFollowButton.translatesAutoresizingMaskIntoConstraints = false
        followingLabel.translatesAutoresizingMaskIntoConstraints = false
        
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
            descriptionTextView.bottomAnchor.constraint(equalTo: editProfileFollowButton.topAnchor, constant: -10),
            
            editProfileFollowButton.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -10),
            editProfileFollowButton.widthAnchor.constraint(equalToConstant: 100),
            editProfileFollowButton.heightAnchor.constraint(equalToConstant: 34),
            editProfileFollowButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),

            topDividerView.rightAnchor.constraint(equalTo: self.rightAnchor),
            topDividerView.leftAnchor.constraint(equalTo: self.leftAnchor),
            topDividerView.bottomAnchor.constraint(equalTo: stackView.topAnchor),
            topDividerView.heightAnchor.constraint(equalToConstant: 0.5),
            
            bottomDividerView.rightAnchor.constraint(equalTo: self.rightAnchor),
            bottomDividerView.leftAnchor.constraint(equalTo: self.leftAnchor),
            bottomDividerView.topAnchor.constraint(equalTo: stackView.bottomAnchor),
            bottomDividerView.heightAnchor.constraint(equalToConstant: 0.5),
            
            followingLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            followingLabel.leadingAnchor.constraint(equalTo: editProfileFollowButton.trailingAnchor, constant: 10),
            followingLabel.heightAnchor.constraint(equalToConstant: 20),
            followingLabel.topAnchor.constraint(equalTo: editProfileFollowButton.topAnchor),
          
        ])
        

        
        
    }
    
    @objc func followingCountTapped(){
        
        if let user = self.user {
            
            delegate?.goToFollowingPage(user: user)
            
        } else {
            
            guard let email = Auth.auth().currentUser?.email else { return }
            Firestore.fetchUserWithEmail(email: email) { (user, err) in
                
                if err {
                    
                    print("could not fetch collowing count for page")
                    return
                    
                }
                
                guard let user = user else { return }
                self.delegate?.goToFollowingPage(user: user)
                
            }
            
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}
