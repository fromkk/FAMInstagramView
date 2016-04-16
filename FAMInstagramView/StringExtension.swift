//
//  StringExtension.swift
//  FAMInstagramView
//
//  Created by Kazuya Ueoka on 2016/04/17.
//  Copyright © 2016年 fromKK. All rights reserved.
//

import Foundation

public extension NSData
{
    public func sha256() -> String?
    {
        var digest = [UInt8](count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)
        CC_SHA256(self.bytes, CC_LONG(self.length), &digest)
        var result :String = ""
        for index in 0..<32
        {
            result += (String(format: "%02x", digest[index]))
        }
        return result
    }
}

public extension String
{
    public func sha256() -> String?
    {
        return self.dataUsingEncoding(NSUTF8StringEncoding)?.sha256()
    }
}

public extension NSString
{
    public func sha256() -> String?
    {
        return self.dataUsingEncoding(NSUTF8StringEncoding)?.sha256()
    }
}