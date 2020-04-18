//
//  NewProfileViewController.swift
//  Discuss
//
//  Created by Harsh Motwani on 11/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit
import Firebase

class NewProfileViewController: UIViewController {
    
    let db : Firestore = Firestore.firestore()
    
    let saveButton: UIButton = {
        
        let button = UIButton()
        
        return button
        
    }()
    
    let currentUser = Auth.auth().currentUser
    
    let nameLabel: UILabel = {
        
        let label = UILabel()
        
        return label
        
    }()
    
    
    let descriptionLabel: UILabel = {
        
        let label = UILabel()
        
        return label
        
    }()
    
    let nameTextField : UITextField = {
        
        let textfield = UITextField()
        
        return textfield;
        
        
    }()
    
    let descriptionTextView: UITextView = {
        
        let textView = UITextView();
        
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)

        self.view.backgroundColor = .systemBackground
        
        self.view.addSubview(nameTextField);
        self.view.addSubview(descriptionTextView);
        self.view.addSubview(nameLabel);
        self.view.addSubview(descriptionLabel);
        self.view.addSubview(saveButton);
        
        
        nameTextField.translatesAutoresizingMaskIntoConstraints = false;
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false;
        nameLabel.translatesAutoresizingMaskIntoConstraints = false;
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false;
        saveButton.translatesAutoresizingMaskIntoConstraints = false;
        
        nameTextField.backgroundColor = .systemGray3
        nameTextField.placeholder = "Enter Display Name"
        nameTextField.layer.cornerRadius = 5.0
        nameTextField.textAlignment = .center
        nameTextField.textColor = .systemBlue
        
        descriptionTextView.backgroundColor = .systemGray3
        descriptionTextView.layer.cornerRadius = 5.0
        descriptionTextView.textAlignment = .center
        descriptionTextView.textColor = .label
        
        nameLabel.text = "Display Name"
        nameLabel.font = UIFont.boldSystemFont(ofSize: 30)
        nameLabel.textColor = .label
        nameLabel.textAlignment = .center
        
        descriptionLabel.text = "Enter Description"
        descriptionLabel.font = UIFont.boldSystemFont(ofSize: 30)
        descriptionLabel.textColor = .label
        descriptionLabel.textAlignment = .center
        
        
        saveButton.backgroundColor = .label
        saveButton.setTitle("SAVE", for: .normal)
        saveButton.setTitleColor(.systemBackground, for: .normal)
        saveButton.layer.cornerRadius = 5;
        
        
        NSLayoutConstraint.activate([
            nameTextField.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10),
            nameTextField.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant:10),
            nameTextField.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 200),
            nameTextField.heightAnchor.constraint(equalToConstant: 40),

            nameLabel.bottomAnchor.constraint(equalTo: self.nameTextField.topAnchor, constant: -10),
            nameLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10),
            nameLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10),
            nameLabel.heightAnchor.constraint(equalToConstant: 50),
            
            descriptionLabel.topAnchor.constraint(equalTo: self.nameTextField.bottomAnchor, constant: 20),
            descriptionLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10),
            descriptionLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 50),
            
            descriptionTextView.topAnchor.constraint(equalTo: self.descriptionLabel.bottomAnchor, constant:10),
            descriptionTextView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10),
            descriptionTextView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 200),
            
            saveButton.topAnchor.constraint(equalTo: self.descriptionTextView.bottomAnchor, constant: 20),
            saveButton.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -10),
            saveButton.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 10),
            saveButton.heightAnchor.constraint(equalToConstant: 50),

        ])
        
        saveButton.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        
        
    }
    
    @objc func handleSave(){
        
        if nameTextField.text?.isEmpty ?? false {
            
            let alert = UIAlertController(title: "Please fill in the display name", message: "The display name is a required field", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)

            
        } else {
            
            guard let email = currentUser?.email else { return }
            
            let docData: [String: Any] = [
                
                "displayName": self.nameTextField.text ?? "",
                "description": self.descriptionTextView.text ?? ""
                
            ]
            
            db.collection("users").document(email).setData(docData) { (err) in
                
                if let err = err{
                    
                    print("Could not make user ", err)
                    return
                }
                
                print("Successfully created Profile!")
                
                self.dismiss(animated: true, completion: nil)
                
            }
            
            
        }
        
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    

    
    
}

