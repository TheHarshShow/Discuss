//
//  EditProfilePage.swift
//  Discuss
//
//  Created by Harsh Motwani on 18/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class EditProfilePage: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let currentUser = Auth.auth().currentUser
    
    let db = Firestore.firestore()
    
    let storage = Storage.storage()
    
    var activityIndicator = UIActivityIndicatorView()
    
    var backgroundImage: UIImage?
    
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
        label.adjustsFontSizeToFitWidth = true
        return label
        
    }()
    
    let editImageButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("Edit Image", for: .normal)
        button.clipsToBounds = true
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 25
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        return button
        
    }()
    
    var temporaryConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.large
        
        self.view.backgroundColor = UIColor.label.withAlphaComponent(0.8)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setupViews()
        
        saveButton.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        editImageButton.addTarget(self, action: #selector(handleEditImage), for: .touchUpInside)
        
    }
    
    fileprivate func setupViews(){
        
        self.view.addSubview(displayNameField)
        self.view.addSubview(descriptionTextView)
        self.view.addSubview(saveButton)
        self.view.addSubview(descriptionLabel)
        self.view.addSubview(infoLabel)
        self.view.addSubview(activityIndicator)
        self.view.addSubview(editImageButton)
        
        displayNameField.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        editImageButton.translatesAutoresizingMaskIntoConstraints = false
        
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
            descriptionLabel.rightAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 50),
            
            descriptionTextView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10),
            descriptionTextView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10),
            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            descriptionTextView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -20),
            
            editImageButton.leftAnchor.constraint(equalTo: descriptionLabel.rightAnchor, constant: 10),
            editImageButton.topAnchor.constraint(equalTo: descriptionLabel.topAnchor),
            editImageButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10),
            editImageButton.bottomAnchor.constraint(equalTo: descriptionLabel.bottomAnchor),
            
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
        
        activityIndicator.startAnimating()
        saveButton.isEnabled = false
        self.dismissKeyboard()
        
        guard let email = currentUser?.email else { return }
        
        let displayName = displayNameField.text
        let description = descriptionTextView.text
        
        if displayName?.count ?? 0 > 0 {
            
            db.collection("users").document(email).setData(["displayName": displayName ?? ""], merge: true) { (err) in
                
                if let err = err {
                    
                    print("could not change display name", err)
                    self.activityIndicator.stopAnimating()
                    self.saveButton.isEnabled = true
                    return
                    
                }
                
                self.saveButton.isEnabled = true
                self.activityIndicator.stopAnimating()
                self.dismiss(animated: true, completion: nil)
                
            }
            
        }
        
        if description?.count ?? 0 > 0 {
            
            db.collection("users").document(email).setData(["description": description ?? ""], merge: true) { (err) in
                
                if let err = err {
                
                    print("could not change description", err)
                    self.activityIndicator.stopAnimating()
                    self.saveButton.isEnabled = true
                    return
                    
                }
                
                self.saveButton.isEnabled = true
                self.activityIndicator.stopAnimating()
                self.dismiss(animated: true, completion: nil)
                
            }
            
        }
        
        
            
        handlePostImage()
            
            
        
        
    }
    
    fileprivate func handlePostImage(){
        
        guard let image = backgroundImage else { return }
        guard let email = currentUser?.email else { return }
        guard let data = image.pngData() else { return }
        
        let storageRef = storage.reference().child("userImages").child("\(email).png")
            
        storageRef.putData(data, metadata: nil) { (meta, err) in
            
            if let err = err {
                
                print("could not change background image", err)
                self.dismiss(animated: true, completion: nil)
                return
                
            }
            
            storageRef.downloadURL { (url, err) in
                
                if let err = err {
                    
                    print("could not download url", err)
                    self.activityIndicator.stopAnimating()
                    self.dismiss(animated: true, completion: nil)
                    return
                    
                }
                
                guard let url = url else { return }
                
                self.db.collection("users").document(email).setData(["profilePictureUrl": url.absoluteString], merge: true) { (err) in
                    
                    if let err = err {
                        
                        print("could not update url", err)
                        self.activityIndicator.stopAnimating()
                        self.dismiss(animated: true, completion: nil)
                        return
                        
                    }
                    
                    self.activityIndicator.stopAnimating()
                    self.dismiss(animated: true, completion: nil)
                    
                }
                
                
                
            }
            
        }
        
    }
    
    @objc func handleEditImage(){
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            backgroundImage = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
            backgroundImage = originalImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
}
