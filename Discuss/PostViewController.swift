//
//  PhotoSelectorController.swift
//  Discuss
//
//  Created by Harsh Motwani on 12/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit
import Firebase

class PostViewController: UIViewController, UITextFieldDelegate {
    
    
    let postTextField: UITextField = {
        
        let tf = UITextField()
        
        tf.backgroundColor = .systemGray3
        tf.font = UIFont.boldSystemFont(ofSize: 20)
        tf.placeholder = "Post Title"
        tf.layer.cornerRadius = 3
        tf.textAlignment = .center
        
        return tf
        
    }()
    
    let countLabel: UILabel = {
        
        let label = UILabel()
        
        label.text = "21"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .green
        
        return label
        
    }()
    
    let descriptionTextView: UITextView = {
        
        let tv = UITextView()
        tv.backgroundColor = .systemGray3
        tv.font = UIFont.systemFont(ofSize: 12)
        tv.layer.cornerRadius = 3
        return tv
        
    }()
    
    let postButton: UIButton = {
        
        let button = UIButton()
        
        button.backgroundColor = .label
        button.setTitleColor(.systemBackground, for: .normal)
        button.layer.cornerRadius = 5
        button.setTitle("POST", for: .normal)
        
        return button
        
    }()
    
    let db = Firestore.firestore()
    
    var temporaryConstraint: NSLayoutConstraint?
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField ==  postTextField{
            
            
            let currentText = postTextField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else {
                
                return false
                
            }
            
            
            let updateText = currentText.replacingCharacters(in: stringRange, with: string)
            
            if updateText.count > 21 { return false }
            
            countLabel.text = "\(21-(postTextField.text?.count ?? 0))"

            countLabel.text = "\(21-updateText.count)"
            
            switch updateText.count {
            case let x where x <= 10:
                countLabel.textColor = .green
            case let x where x <= 15:
                countLabel.textColor = .systemYellow
            default:
                countLabel.textColor = .red
            }
            
            return updateText.count <= 21
        }
        return true
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        view.backgroundColor = .tertiarySystemBackground
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        
        
        setupNavigationButtons()
        
        setupUIElements()
    }
    
    fileprivate func setupUIElements(){
        
        self.view.addSubview(postTextField)
        self.view.addSubview(descriptionTextView)
        self.view.addSubview(countLabel)
        self.view.addSubview(postButton)
        
        postTextField.delegate = self
        
        postTextField.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        postButton.translatesAutoresizingMaskIntoConstraints = false
        
        temporaryConstraint = postButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        
        postButton.addTarget(self, action: #selector(handlePost), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
        
            postTextField.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10),
            postTextField.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10),
            postTextField.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 50),
            postTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),
            
            countLabel.leftAnchor.constraint(equalTo: postTextField.leftAnchor),
            countLabel.topAnchor.constraint(equalTo: postTextField.bottomAnchor, constant: 10),
            countLabel.rightAnchor.constraint(equalTo: postTextField.rightAnchor),
            countLabel.heightAnchor.constraint(equalToConstant: 15),
            
            descriptionTextView.topAnchor.constraint(equalTo: self.countLabel.bottomAnchor, constant: 10),
            descriptionTextView.leftAnchor.constraint(equalTo: self.countLabel.leftAnchor, constant: 0),
            descriptionTextView.rightAnchor.constraint(equalTo: self.countLabel.rightAnchor, constant: 0),
            descriptionTextView.bottomAnchor.constraint(equalTo: self.postButton.topAnchor, constant: -10),
            
            postButton.rightAnchor.constraint(equalTo: self.postTextField.rightAnchor, constant: 0),
            postButton.leadingAnchor.constraint(equalTo: self.postTextField.leadingAnchor, constant: 0),
            postButton.heightAnchor.constraint(equalToConstant: 50),
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
    
    fileprivate func setupNavigationButtons(){
        
        navigationController?.navigationBar.tintColor = .label
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(handleCancel))
        
    }
    
    @objc fileprivate func handleCancel(){
        
        self.dismiss(animated: true, completion: nil)
        
    }
    

    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @objc func handlePost(){
        
        
        let postTitle = postTextField.text ?? ""
        
        let description = descriptionTextView.text ?? ""
        
        if postTitle.count == 0 {
            
            let alert = UIAlertController(title: "No Title Provided", message: "Please Fill in the Title field", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        } else if description.count == 0 {
            
            let alert = UIAlertController(title: "No Description Provided", message: "Please Fill in the Description field", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
            
        } else {
            
            
            guard let currentUser = Auth.auth().currentUser else { return }
            guard let email = currentUser.email else { return }
            let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
            
            let docData: [String: Any] = [
            
                "postTitle": postTitle,
                "description": description,
                "timestamp": timestamp,
                "userEmail": email
            
            ]
            
            db.collection("posts").document("\(email)-\(timestamp)").setData(docData) { (err) in
                
                if let err = err {
                    
                    print("Could not post", err)
                    return
                    
                }
                
                self.dismiss(animated: true, completion: nil)
                
            }
            
        }
        
        
    }
    
}
