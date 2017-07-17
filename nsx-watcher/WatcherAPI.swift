//
//  WatcherAPI.swift
//  nsx-watcher
//
//  Created by Kelvin Lam on 17/7/17.
//  Copyright © 2017 Henshin Soft Pty Ltd. All rights reserved.
//

import UIKit
import AFNetworking
import HTMLKit

class WatcherAPI: NSObject {
    
    var url = "http://prestigemotorsport.com.au/wp-admin/admin-ajax.php"
    
    func postCalls() {
        let headers = [
            "Pragma": "no-cache",
            "Cache-Control": "no-cache",
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36",
            "Content-Type": "application/x-www-form-urlencoded",
            "X-Requested-With": "XMLHttpRequest",
            "Accept": "application/json"
        ]
        
        let config = URLSessionConfiguration.default
        let manager = AFURLSessionManager(sessionConfiguration: config)
        let serialiser = AFJSONResponseSerializer(readingOptions: .mutableContainers)
        serialiser.acceptableContentTypes = Set(["application/json", "text/html"])
        manager.responseSerializer = serialiser
        let request = AFJSONRequestSerializer(writingOptions: .prettyPrinted).request(withMethod: "POST", urlString: url, parameters: nil, error: nil)
        
        // Apply headers
        for (key, val) in headers {
            request.addValue(val, forHTTPHeaderField: key)
        }
        
        let fields = [
            "action": "search_results_car",
            "limit_start": "0",
            "auction-date": "Past",
            "marka_id": "5",
            "model_id": "604",
            "year_from": "1989",
            "year_to": "2008",
            "transmissions": "Manual"
        ]
        
        let queryString = makeQueryString(with: fields)
        request.httpBody = queryString.data(using: .utf8)
        
        
        let dataTask = manager.dataTask(with: request as URLRequest, completionHandler: { (response, responseObject, error) in
//            debugPrint("response: \(response).  \n\nresponseObject= \(responseObject)")
            
            if let error = error {
                debugPrint("error = \(error)")
            } else {
                if let json = responseObject as? [AnyHashable: Any] {
                    debugPrint("type = \(type(of: json["total"]!))")
                    if let total = json["total"] as? NSNumber {
                        print("total = \(total)")
                    } else if let totalString = json["total"] as? String, let total = Int(totalString) {
                        print("wtf man total is string: \(total)")
                        
                        if total > 0, let carsHtml = json["cars_html"] as? String {
                            let parser = HTMLParser(string: carsHtml)
                            let context = HTMLElement(tagName: "jas-car-item")
                            
                            let nodes = parser.parseFragment(withContextElement: context)
                            
                            for node in nodes {
                                let childNodes = node.childNodes.array as! [HTMLElement]
                                
                                let contentNode = childNodes.filter({ elem -> Bool in
                                    return elem.className == "jas-car-item-content"
                                }).first!
                                
                                let auctionDateNode = (contentNode.childNodes.array as! [HTMLElement]).filter({ (elem: HTMLElement) -> Bool in
                                    return elem.className == "jas-auction-date" && elem.outerHTML.contains("Auction Date")
                                }).first!
                                
                                let auctionDateSpanString = (auctionDateNode.childNodes.lastObject as! HTMLElement).innerHTML
                                
                                debugPrint(contentNode)
                                
                            }
                        } else {
                            
                        }
                    }
                }
            }
        })
        
        dataTask.resume()
    }
    
    
    func makeQueryString(with dictionary: [String: String]) -> String {
        var queryString = ""
        
        for (key, val) in dictionary {
            if queryString.isEmpty == false {
                queryString += "&"
            }
            queryString += key + "=" + val
        }
        
        return queryString
    }
    
}
