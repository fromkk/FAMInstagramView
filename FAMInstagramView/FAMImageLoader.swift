//
//  FAMImageLoader.swift
//  FAMInstagramView
//
//  Created by Kazuya Ueoka on 2016/04/16.
//  Copyright © 2016年 fromKK. All rights reserved.
//

import UIKit

public protocol FAMImageLoaderProtocol {}

public class FAMImageCache : NSCache
{
    private override init() {
        super.init()
        
        self.countLimit = 30
    }
    public static let sharedInstance :FAMImageCache = FAMImageCache()
}

public extension FAMImageLoaderProtocol
{
    typealias FAMImageLoaderComplete = (image :UIImage?) -> ()
    private static func _loadURL(url :NSURL, complete :FAMImageLoaderComplete) -> NSURLSessionTask?
    {
        if let key :String = url.absoluteString.sha256()
        {
            if let image :UIImage = FAMImageCache.sharedInstance.objectForKey(key) as? UIImage
            {
                complete(image: image)
                return nil
            }
        }
        
        guard let request :NSURLRequest = NSURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 60.0) else
        {
            complete(image: nil)
            return nil
        }
        
        let configuration :NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session :NSURLSession = NSURLSession(configuration: configuration)
        let task :NSURLSessionTask = session.dataTaskWithRequest(request) { (result :NSData?, response :NSURLResponse?, error :NSError?) in
            guard let data :NSData = result else
            {
                complete(image: nil)
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                let image :UIImage? = UIImage(data: data)
                complete(image: image)
                
                if let key :String = url.absoluteString.sha256() where nil != image
                {
                    FAMImageCache.sharedInstance.setObject(image!, forKey: key)
                }
            })
        }
        return task
    }
    
    public static func loadImage(path :String, complete :FAMImageLoaderComplete) -> NSURLSessionTask?
    {
        guard let url :NSURL = NSURL(string: path) else
        {
            complete(image :nil)
            return nil
        }
        
        return self._loadURL(url, complete: complete)
    }
    
    public static func loadURL(url :NSURL, complete :FAMImageLoaderComplete) -> NSURLSessionTask?
    {
        return self._loadURL(url, complete: complete)
    }
}

public struct FAMImageLoader :FAMImageLoaderProtocol {}