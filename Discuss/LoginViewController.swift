//
//  LoginViewController.swift
//  Discuss
//
//  Created by Harsh Motwani on 10/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit
import Firebase
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController {

    let signInButton: GIDSignInButton = {
       
        let button = GIDSignInButton()
        
        return button
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .systemBackground
        GIDSignIn.sharedInstance()?.presentingViewController = self
        //        GIDSignIn.sharedInstance().signIn()
                
        view.addSubview(signInButton)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            signInButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant:-50),
            signInButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant:50),
            signInButton.heightAnchor.constraint(equalToConstant: 100)


        ])
    }
    


}

