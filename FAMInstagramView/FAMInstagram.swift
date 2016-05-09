//
//  FAMInstagram.swift
//  FAMInstagramView
//
//  Created by Kazuya Ueoka on 2016/04/16.
//  Copyright © 2016年 fromKK. All rights reserved.
//

import Foundation

public struct FAMInstagramUser
{
    var fullName :String?
    var id :String?
    var profilePicture :String?
    var username :String?
    
    public static func userFromDictionary(dictionary :Dictionary<String, AnyObject>?) -> FAMInstagramUser
    {
        var result :FAMInstagramUser = FAMInstagramUser()
        result.id = dictionary?["id"] as? String
        result.fullName = dictionary?["full_name"] as? String
        result.profilePicture = dictionary?["profile_picture"] as? String
        result.username = dictionary?["username"] as? String
        return result
    }
}

public struct FAMInstagramCaption
{
    var createdTime :String?
    var from :FAMInstagramUser?
    var id :String?
    var text :String?
    
    public static func captionFromDictionary(dictionary :Dictionary<String, AnyObject>?) -> FAMInstagramCaption
    {
        var result :FAMInstagramCaption = FAMInstagramCaption()
        result.createdTime = dictionary?["created_time"] as? String
        result.from = FAMInstagramUser.userFromDictionary(dictionary?["from"] as? Dictionary<String, AnyObject>)
        result.id = dictionary?["id"] as? String
        result.text = dictionary?["text"] as? String
        return result
    }
}

public struct FAMInstagramComment
{
    var createdTime :String?
    var from :FAMInstagramUser?
    var id :String?
    var text :String?
    
    public static func commentFromDictionary(dictionary :Dictionary<String, AnyObject>?) -> FAMInstagramComment
    {
        var result :FAMInstagramComment = FAMInstagramComment()
        result.createdTime = dictionary?["created_time"] as? String
        result.from = FAMInstagramUser.userFromDictionary(dictionary?["from"] as? Dictionary<String, AnyObject>)
        result.id = dictionary?["id"] as? String
        result.text = dictionary?["text"] as? String
        return result
    }
}

public struct FAMInstagramImage
{
    var url :String?
    var width :String?
    var height :String?
    
    public static func imageFromDictionary(dictionary :Dictionary<String, AnyObject>?) -> FAMInstagramImage
    {
        var result :FAMInstagramImage = FAMInstagramImage()
        result.url = dictionary?["url"] as? String
        result.width = dictionary?["width"] as? String
        result.height = dictionary?["height"] as? String
        return result
    }
}

public struct FAMInstagramItem
{
    var attribution :String?
    var caption :FAMInstagramCaption?
    var comments :[FAMInstagramComment] = []
    var createdTime :String?
    var filter :String?
    var id :String?
    var lowResolution :FAMInstagramImage?
    var standardResolution :FAMInstagramImage?
    var thumbnail :FAMInstagramImage?
    var likes :[FAMInstagramUser] = []
    var link :String?
    var tags :[String] = []
    var type :String?
    var user :FAMInstagramUser?
    
    public static func itemFromDictionary(dictionary :Dictionary<String, AnyObject>?) -> FAMInstagramItem{
        var item :FAMInstagramItem = FAMInstagramItem()
        item.attribution = dictionary?["attribution"] as? String
        item.caption = FAMInstagramCaption.captionFromDictionary(dictionary?["caption"] as? Dictionary<String, AnyObject>)
        
        if let comments :Dictionary<String, AnyObject> = (dictionary?["comments"] as? Dictionary<String, AnyObject>)
        {
            if let data :[Dictionary<String, AnyObject>] = comments["data"] as? [Dictionary<String, AnyObject>]
            {
                item.comments = data.map {
                    FAMInstagramComment.commentFromDictionary($0)
                }
            }
        }
        
        item.createdTime = dictionary?["created_time"] as? String
        item.filter = dictionary?["filter"] as? String
        item.id = dictionary?["id"] as? String
        
        if let images :Dictionary<String, AnyObject> = dictionary?["images"] as? Dictionary<String, AnyObject>
        {
            item.lowResolution = FAMInstagramImage.imageFromDictionary(images["low_resolution"] as? Dictionary<String, AnyObject>)
            item.standardResolution = FAMInstagramImage.imageFromDictionary(images["standard_resolution"] as? Dictionary<String, AnyObject>)
            item.thumbnail = FAMInstagramImage.imageFromDictionary(images["thumbnail"] as? Dictionary<String, AnyObject>)
        }
        
        if let likes :Dictionary<String, AnyObject> = dictionary?["likes"] as? Dictionary<String, AnyObject>
        {
            if let data :[Dictionary<String, AnyObject>] = likes["data"] as? [Dictionary<String, AnyObject>]
            {
                item.likes = data.map {
                    FAMInstagramUser.userFromDictionary($0)
                }
            }
        }
        item.link = dictionary?["link"] as? String
        item.tags = (dictionary?["tags"] as? [String]) ?? []
        item.type = dictionary?["type"] as? String
        
        if let user :Dictionary<String, AnyObject> = dictionary?["user"] as? Dictionary<String, AnyObject>
        {
            item.user = FAMInstagramUser.userFromDictionary(user)
        }
        
        return item
    }
}

public enum FAMInstagramConfiguration : String
{
    case AccessToken = "2614388.a450b0b.db753a321ece424bb01c9466d3223c6c"
    case UserId = "1648170148"
    case Tag    = "fammの無料フォトカレンダー"
}

public enum FAMInstagramApis : String
{
    public typealias FAMInstagramCompletion = (result: Dictionary<String, AnyObject?>?, error :NSError?) -> ()
    
    private static var endpoint :String
    {
        return "https://api.instagram.com/v1"
    }
    
    case userMediaRecent = "/users/%@/media/recent"
    case tagsMediaRecent = "/tags/%@/media/recent"
    
    private static func fetchUrl(urlString :String, completion :FAMInstagramCompletion)
    {
        print(self.dynamicType, #function, urlString)
        guard let url :NSURL = NSURL(string: urlString) else
        {
            completion(result :nil, error :nil)
            return
        }
        
        guard let request :NSURLRequest = NSURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 30.0) else
        {
            completion(result: nil, error: nil)
            return
        }
        
        let configuration :NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session :NSURLSession = NSURLSession(configuration: configuration)
        let task :NSURLSessionTask = session.dataTaskWithRequest(request) { (result, response, error) in
            guard let data :NSData = result else
            {
                completion(result: nil, error: error)
                return
            }
            
            do
            {
                if let result :Dictionary<String, AnyObject> = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? Dictionary<String, AnyObject>
                {
                    completion(result: result, error: nil)
                } else
                {
                    completion(result: nil, error: nil)
                }
            } catch let err as NSError {
                completion(result: nil, error: err)
            }
            
        }
        task.resume()
    }
    
    public static func mediasFromUserId(userId :String, completion :FAMInstagramCompletion)
    {
        let endpoint :String = self.endpoint
        let path :String = String(format: self.userMediaRecent.rawValue, userId)
        let accessToken :String = FAMInstagramConfiguration.AccessToken.rawValue
        let urlString :String = "\(endpoint)\(path)?access_token=\(accessToken)"
        self.fetchUrl(urlString, completion: completion)
    }

    public static func mediasFromTag(tag :String, completion :FAMInstagramCompletion)
    {
        guard let escapedTag :String = tag.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) else
        {
            completion(result: nil, error: nil)
            return
        }

        let endpoint :String = self.endpoint
        let path :String = String(format: self.tagsMediaRecent.rawValue, escapedTag)
        let accessToken :String = FAMInstagramConfiguration.AccessToken.rawValue
        let urlString :String = "\(endpoint)\(path)?access_token=\(accessToken)"
        self.fetchUrl(urlString, completion: completion)
    }
}