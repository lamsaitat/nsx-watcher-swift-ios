//
//  URLComponents+queryItems.swift
//  Tenplay
//
//  Created by Kelvin Lam on 24/4/17.
//  Copyright © 2017 Network Ten Pty Ltd. All rights reserved.
//

import UIKit

extension URLComponents {
    var queryDictionary: [AnyHashable: AnyObject]? {
        
        guard let queryItems = queryItems else {
            return nil
        }
        
        var queryDict = [AnyHashable: AnyObject]()
        
        for item in queryItems {
            if let itemValue = item.value {
                queryDict[item.name] = itemValue as AnyObject
            } else if let _ = queryDict[item.name] {
                queryDict.removeValue(forKey: item.name)
            }
        }
        
        return queryDict
    }
}
