//
//  Extensions.swift
//  ConnectU
//
//  Created by Sun&KK on 11/26/17.
//  Copyright © 2017 CSE438. All rights reserved.
//

import UIKit

//  use for caching image from database, solve the problem: constantly fetching image from database when scrolling tableview
let imageCache = NSCache<AnyObject, UIImage>()

//  add func for UIImageView to get image from cache
extension UIImageView {
    
    func loadImageUsingCacheWithURL(urlString: String){
        //check cache for image first, if cahce has the image, just get it and return
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) {
            self.image = cachedImage
            return
        }
        
        // if no cache, fetch data from database
        let url = URL(string: urlString)
        if(url != nil)
        {
            //'dispatch_get_main_queue()' has been replaced by property 'DispatchQueue.main'
            //'dispatch_async' has been replaced by instance method 'DispatchQueue.async(execute:)'
            DispatchQueue.global(qos: .background).async {
                print("This is run on the background queue")
                let data = try? Data(contentsOf: url!)
                let image = UIImage(data: data!)
                
                DispatchQueue.main.async {
                    print("This is run on the main queue, after the previous code in outer block")
                    imageCache.setObject(image!, forKey: urlString as AnyObject)
                    self.image = image
                }
            }
        }
        else
        {
            self.image = UIImage(named: "default-avatar")
        }
        
    }
}
