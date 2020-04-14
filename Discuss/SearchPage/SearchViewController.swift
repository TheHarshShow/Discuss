//
//  SearchViewController.swift
//  Discuss
//
//  Created by Harsh Motwani on 14/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit

class SearchViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
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
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchCell
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 66)
    }
    
    
}
