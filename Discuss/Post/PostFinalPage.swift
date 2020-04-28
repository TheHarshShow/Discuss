//
//  PostDescriptionPage.swift
//  Discuss
//
//  Created by Harsh Motwani on 18/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class PostFinalPage: UIViewController {
    
    let currentUser = Auth.auth().currentUser
    
    let storage = Storage.storage()
    
    var color: String? {
        
        didSet {
            
            guard let color = color else { return }
            titleLabel.textColor = colorDict[color]
        }
        
    }
    
    var font: String? {
        
        didSet{
            
            guard let font = font else { return }
            titleLabel.font = UIFont(name: font, size: 13)
            
        }
        
    }
    
    var postTitle: String? {
        
        didSet {
            
            titleLabel.text = postTitle
            
        }
        
    }
    
    var postImage: UIImage? {
        
        didSet {
            
            stampImageView.image = postImage
            
        }
        
    }
    
    let descriptionTextView: UITextView = {
        
        let tv = UITextView()
        tv.backgroundColor = .systemGray3
        tv.font = UIFont.systemFont(ofSize: 13)
        tv.layer.cornerRadius = 3
        tv.backgroundColor = .systemRed
        tv.clipsToBounds = true
        tv.layer.cornerRadius = 5
        return tv
        
    }()
    
    let stampImageView: UIImageView = {
        
        let iv = UIImageView()
        
        iv.backgroundColor = .systemTeal
        iv.layer.cornerRadius = 5
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true

        return iv
        
    }()
    
    let postButton: UIButton = {
           
        let button = UIButton(type: .system)
           
           button.backgroundColor = .label
           button.setTitleColor(.systemBackground, for: .normal)
           button.layer.cornerRadius = 5
           button.setTitle("POST", for: .normal)
           
           return button
           
       }()
    
    let titleLabel: UITextView = {
        
        let label = UITextView()
        
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textAlignment = .center
        label.backgroundColor = .none
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.isEditable = false
        label.isScrollEnabled = false
        
        return label
        
    }()
    
    var temporaryConstraint: NSLayoutConstraint?
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.view.backgroundColor = .systemBackground
        
        self.setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.postButton.addTarget(self, action: #selector(handlePost), for: .touchUpInside)
        
    }
    
    
    fileprivate func setupViews(){
        
        self.view.addSubview(descriptionTextView)
        self.view.addSubview(stampImageView)
        self.view.addSubview(titleLabel)
        self.view.addSubview(postButton)
    
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        postButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        stampImageView.translatesAutoresizingMaskIntoConstraints = false
        
        temporaryConstraint = postButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        
        NSLayoutConstraint.activate([
        
            stampImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            stampImageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100),
            stampImageView.heightAnchor.constraint(equalToConstant: 100),
            stampImageView.widthAnchor.constraint(equalToConstant: 100),
            
            descriptionTextView.topAnchor.constraint(equalTo: stampImageView.bottomAnchor, constant: 20),
            descriptionTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            descriptionTextView.bottomAnchor.constraint(equalTo: postButton.topAnchor, constant: -20),
            
            postButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20),
            postButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            postButton.heightAnchor.constraint(equalToConstant: 50),
            temporaryConstraint!,
            
            titleLabel.leftAnchor.constraint(equalTo: stampImageView.leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: stampImageView.rightAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: stampImageView.centerYAnchor),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
        
        ])
        
    }
    
    @objc func keyboardWillShow(notification: Notification) {

       if let userInfo = notification.userInfo {
            
        guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            temporaryConstraint?.constant = -keyboardFrame.height + view.safeAreaInsets.bottom - 10
            
        }

        
    }

    @objc func keyboardWillHide(notification: Notification) {
        
        temporaryConstraint?.constant = -20
        

    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @objc func handlePost(){
        
        db.collection("posts")
        guard let postTitle = postTitle else { return }
        guard let email = currentUser?.email else { return }
        
        var postDict = [String: Any]()
        postDict["postTitle"] = postTitle
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        postDict["timestamp"] = timestamp
        postDict["description"] = descriptionTextView.text ?? ""
        postDict["userEmail"] = email
        postDict["font"] = self.font ?? ""
        postDict["color"] = self.color ?? ""
        
        db.collection("posts").document("\(email)-\(timestamp)").setData(postDict) { (err) in
            
            if let err = err {
                print("could not make post", err)
                return
            }
            self.handlePostImage(email: email, timestamp: timestamp)
            
        }
        
    }
    
    fileprivate func handlePostImage(email: String, timestamp: Int64){
        
        if self.postImage == nil {
            self.dismiss(animated: true, completion: nil)
            return
        }
        guard let image = self.postImage else { return }
        
        let storageRef = storage.reference().child("postImages").child("\(email)-\(timestamp).png")
        guard let data = image.pngData() else { return }
        
        print(data)
        
        storageRef.putData(data, metadata: nil) { (meta, err) in
            
            if let err = err {
                print("could not upload image", err)
                return
            }
            storageRef.downloadURL { (url, err) in
                
                if let err = err {
                    print("could not get url", err)
                    return
                }
                
                guard let url = url else { return }
                
                self.db.collection("posts").document("\(email)-\(timestamp)").setData(["imageUrl": url.absoluteString], merge: true) { (err) in
                    
                    if let err = err {
                        print("could not update url",err)
                        return
                    }
                    self.dismiss(animated: true, completion: nil)
                }
                
            }
            
        }
        
    }
    
}
