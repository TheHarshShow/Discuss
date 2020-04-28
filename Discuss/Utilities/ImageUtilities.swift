//
//  Cashe.swift
//  Discuss
//
//  Created by Harsh Motwani on 18/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit

var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    var IMAGEURL: String?
    
    func loadImageFromUrl(imageUrl: String){
        
        IMAGEURL = imageUrl
        
        print("URL:", IMAGEURL!)
        
        if IMAGEURL?.count ?? 0 == 0 {
            
            self.image = nil
            return
            
        }
        
        if imageCache[imageUrl] != nil {
            self.image = imageCache[imageUrl]
            return
        } else {
            
            guard let url = URL(string: imageUrl) else { return }
            
            URLSession.shared.dataTask(with: url) { (data, response, err) in
                
                if let err = err {
                    
                    print("failed to fetch post image", err)
                    return
                    
                }
                
                if url.absoluteString != self.IMAGEURL { return }
                
                guard let data = data else { return }
                let image = UIImage(data: data)
                
                DispatchQueue.main.async {
                    
                    imageCache[self.IMAGEURL!] = image
                    self.image = image

                }
                
            }.resume()
            
        }
        
    }
    
}
