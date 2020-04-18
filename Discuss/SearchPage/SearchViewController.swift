//
//  SearchViewController.swift
//  Discuss
//
//  Created by Harsh Motwani on 14/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit
import Firebase

class SearchViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    let cellId = "cellId"
    
    let currentUser = Auth.auth().currentUser
    
    let db = Firestore.firestore()
    
    var users = [User]()
    var filteredUsers = [User]()
    
   let searchBar: UISearchBar = {
        
        let sb = UISearchBar()
        sb.placeholder = "Enter Email or Display Name"
        sb.barTintColor = .systemGray3
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = .systemGray4
        
        return sb
        
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(SearchCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .systemBackground
        collectionView.keyboardDismissMode = .onDrag
        
        searchBar.delegate = self
        
        setupNavBar()
        fetchUsers()

    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty || searchText == "" {
            
            filteredUsers = users
            
        } else {
            
            
            self.filteredUsers = self.users.filter { (user) -> Bool in
                
                return (user.displayName.contains(searchText) || user.email.lowercased().contains(searchText.lowercased()))
                
            }
            
        }
        

        
        self.collectionView.reloadData()
        
    }
    
    fileprivate func setupNavBar(){
        
        
        guard let navBar = navigationController?.navigationBar else { return }
        
        navBar.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
        
            searchBar.bottomAnchor.constraint(equalTo: navBar.bottomAnchor),
            searchBar.leftAnchor.constraint(equalTo: navBar.leftAnchor, constant: 10),
            searchBar.rightAnchor.constraint(equalTo: navBar.rightAnchor, constant: -10),
            searchBar.topAnchor.constraint(equalTo: navBar.topAnchor),
        
        ])
        
    }
    fileprivate func fetchUsers(){
        db.collection("users").addSnapshotListener { (snapshot, err) in
            if let err = err {
                print("couldn't fetch user snapshot", err)
                return
            }
            
            guard let documentChanges = snapshot?.documentChanges else { return }
            
            guard let email = self.currentUser?.email else { return }
            
            for dc in documentChanges {
                
                switch dc.type {
                case .added:
                    let document = dc.document
                    
                    let docData = document.data()
                    
                    if document.documentID == email { continue }
                    
                    let user = User(dictionary: docData, email: document.documentID)
                    
                    self.users.append(user)
                    
                    self.filteredUsers.append(user)
                    
                    self.collectionView.reloadData()
                    
                case .modified:
                    print("document modified")
                    
                    if dc.document.documentID == email { continue }

                    let docData = dc.document.data()
                    let user = User(dictionary: docData, email: dc.document.documentID)
                    
                    if let index = self.users.firstIndex(where: { (userr) -> Bool in
                        return userr.email == user.email
                    }) {
                        
                        self.users[index] = user
                    }
                    if let index = self.filteredUsers.firstIndex(where: {
                        (userr)->Bool in return userr.email == user.email
                        
                    }) {
                        
                        self.filteredUsers[index] = user
                        
                    }
                    
                case .removed:
                    print("document removed")
                    
                    if dc.document.documentID == email { continue }

                    let docData = dc.document.data()
                    let user = User(dictionary: docData, email: dc.document.documentID)
                    
                    if let index = self.users.firstIndex(where: { (userr) -> Bool in
                        return userr.email == user.email
                    }) {
                        
                        self.users.remove(at: index)
                    }
                    if let index = self.filteredUsers.firstIndex(where: {
                        (userr)->Bool in return userr.email == user.email
                        
                    }) {
                        
                        self.filteredUsers.remove(at: index)
                        
                    }
                    
                    
                default:
                    print("document changed")
                }
                
            }
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchBar.isHidden = false
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        
        let user = filteredUsers[indexPath.item]
        print(user.email)
        
        let userProfileViewController = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileViewController.userEmail = user.email
        
        navigationController?.pushViewController(userProfileViewController, animated: true)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchCell
        
        cell.user = filteredUsers[indexPath.item]
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 66)
    }
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    

}
