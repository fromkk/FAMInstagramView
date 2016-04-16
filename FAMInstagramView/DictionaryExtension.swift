//
//  DictionaryExtension.swift
//  FAMInstagramView
//
//  Created by Kazuya Ueoka on 2016/04/16.
//  Copyright © 2016年 fromKK. All rights reserved.
//

import Foundation

extension Dictionary
{
    func queryString() -> String
    {
        var result :[String] = []
        for (key, value) in self
        {
            result.append("\(key)=\(value)")
        }
        return result.joinWithSeparator("&")
    }
}