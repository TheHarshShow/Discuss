//
//  EditProfilePage.swift
//  Discuss
//
//  Created by Harsh Motwani on 18/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit
import Firebase

class EditProfilePage: UIViewController {
    
    let currentUser = Auth.auth().currentUser
    
    let db = Firestore.firestore()
    
    let displayNameField: UITextField = {
        
        let tf = UITextField()
        
        tf.textColor = .label
        tf.backgroundColor = .secondarySystemBackground
        tf.textAlignment = .center
        tf.placeholder = "Display name"
        tf.font = UIFont.boldSystemFont(ofSize: 18)
        tf.clipsToBounds = true
        tf.layer.cornerRadius = 5
        
        return tf
        
    }()
    
    let descriptionTextView: UITextView = {
        
        let tv = UITextView()
        tv.textAlignment = .center
        tv.font = UIFont.systemFont(ofSize: 15)
        tv.textColor = .label
        tv.backgroundColor = .secondarySystemBackground
        tv.clipsToBounds = true
        tv.layer.cornerRadius = 5
        
        return tv
        
    }()
    
    let infoLabel: UITextView = {
        
        let label = UITextView()
        label.textColor = .systemBlue
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = "Anything you leave blank will remain the same as before.*"
        label.isScrollEnabled = false
        label.backgroundColor = .none
        
        return label
        
        
    }()
    
    let saveButton: UIButton = {
        
        let button = UIButton()
        button.backgroundColor = .systemTeal
        button.setTitle("Save", for: .normal)
        button.setTitleColor(UIColor.systemBackground, for: .normal)
        button.layer.cornerRadius = 5
        
        return button
        
    }()
    
    let descriptionLabel: UILabel = {
        
        let label = UILabel()
        label.text = "Description"
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 30)
        return label
        
    }()
    
    var temporaryConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.label.withAlphaComponent(0.8)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setupViews()
        
        saveButton.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        
    }
    
    fileprivate func setupViews(){
        
        self.view.addSubview(displayNameField)
        self.view.addSubview(descriptionTextView)
        self.view.addSubview(saveButton)
        self.view.addSubview(descriptionLabel)
        self.view.addSubview(infoLabel)
        
        displayNameField.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        temporaryConstraint = saveButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        
        NSLayoutConstraint.activate([
        
            infoLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20),
            infoLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20),
            infoLabel.bottomAnchor.constraint(equalTo: displayNameField.topAnchor, constant: -10),
            infoLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            
            displayNameField.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10),
            displayNameField.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10),
            displayNameField.heightAnchor.constraint(equalToConstant: 30),
            displayNameField.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100),
            
            descriptionLabel.topAnchor.constraint(equalTo: displayNameField.bottomAnchor, constant: 10),
            descriptionLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10),
            descriptionLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 50),
            
            descriptionTextView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10),
            descriptionTextView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10),
            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            descriptionTextView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -20),
            
            
            saveButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10),
            saveButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10),
            saveButton.heightAnchor.constraint(equalToConstant: 40),
            temporaryConstraint!,
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
    
    @objc func handleSave(){
        
        guard let email = currentUser?.email else { return }
        
        let displayName = displayNameField.text
        let description = descriptionTextView.text
        
        if displayName?.count ?? 0 > 0 {
            
            db.collection("users").document(email).setData(["displayName": displayName ?? ""], merge: true) { (err) in
                
                if let err = err {
                    
                    print("could not change display name", err)
                    return
                    
                }
                
                self.dismiss(animated: true, completion: nil)
                
            }
            
        }
        
        if description?.count ?? 0 > 0 {
            
            db.collection("users").document(email).setData(["description": description ?? ""], merge: true) { (err) in
                
                if let err = err {
                
                    print("could not change description", err)
                    return
                    
                }
                
                self.dismiss(animated: true, completion: nil)
                
            }
            
        }
        
        
    }
    
}
