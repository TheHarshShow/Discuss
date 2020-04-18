//
//  MainTabBarController.swift
//  Discuss
//
//  Created by Harsh Motwani on 10/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let index = viewControllers?.firstIndex(of: viewController)
        
        if index==2{
            
            
            let postViewController = PostViewController()
            let navController = UINavigationController(rootViewController: postViewController)
            
            present(navController, animated: true, completion: nil)
            
            return false
            
        }
        
        return true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        self.tabBar.isHidden = true
            
        
        if Auth.auth().currentUser == nil {
            
            DispatchQueue.main.async {
                
                let loginViewController = LoginViewController()
                
                loginViewController.modalPresentationStyle = .fullScreen
                
                self.present(loginViewController, animated: true, completion: nil)
                
            }
            
            
            return
            
        }
        
        guard let currentUser = Auth.auth().currentUser else {
            print("COULD NOT GET CURRENT USER");
            return
            
        }
        print("USER EMAIL: ", Auth.auth().currentUser?.email ?? "")

        
        let db = Firestore.firestore()
        
        db.collection("users").document(currentUser.email!).addSnapshotListener { (document, err) in
            
            if let err = err {
                
                print(err)
                return
            }
            
            if document?.exists ?? false {
                print("user document exists! ", document?.documentID ?? "")
                
                self.tabBar.isHidden = false
                self.tabBar.tintColor = .label
                
                let layout = UICollectionViewFlowLayout()
                
                
                let userProfileNavController = self.templateNavController(unselectedImage: "profile_unselected", selectedImage: "profile_selected", rootViewController: UserProfileViewController(collectionViewLayout: layout))
               
                let homeNavController = self.templateNavController(unselectedImage: "home_unselected", selectedImage: "home_selected", rootViewController: HomePageViewController(collectionViewLayout: UICollectionViewFlowLayout()))
                
                let searchNavController = self.templateNavController(unselectedImage: "search_unselected", selectedImage: "search_selected", rootViewController: SearchViewController(collectionViewLayout: UICollectionViewFlowLayout()))
               
                let likeNavController = self.templateNavController(unselectedImage: "like_unselected", selectedImage: "like_selected", rootViewController: LikePageViewController(collectionViewLayout: UICollectionViewFlowLayout()))
                
                let plusNavController = self.templateNavController(unselectedImage: "plus_unselected", selectedImage: "plus_unselected")
                
                self.viewControllers = [homeNavController, searchNavController, plusNavController, likeNavController, userProfileNavController]
                
                guard let items = self.tabBar.items else { return }
                
                for item in items{
                    
                    item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
                    
                }
                
            } else {
                
                let newProfileViewController = NewProfileViewController()
                newProfileViewController.modalPresentationStyle = .fullScreen
                self.present(newProfileViewController, animated: true, completion: nil)
                
                
            }
            
            
        }
        
        
        
    }
    
    
    fileprivate func templateNavController(unselectedImage: String, selectedImage: String, rootViewController: UIViewController = UIViewController()) -> UINavigationController{
        
        let homePageViewController = rootViewController
        let homeNavController = UINavigationController(rootViewController: homePageViewController)
        homeNavController.tabBarItem.selectedImage = UIImage(named: selectedImage)
        homeNavController.tabBarItem.image = UIImage(named: unselectedImage)
        
        return homeNavController
        
    }
    
}
