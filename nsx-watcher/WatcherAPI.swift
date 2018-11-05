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
    
    lazy var manager: AFURLSessionManager = {
        AFNetworkActivityIndicatorManager.shared().isEnabled = true
        let config = URLSessionConfiguration.default
        let manager = AFURLSessionManager(sessionConfiguration: config)
        let serialiser = AFJSONResponseSerializer(readingOptions: .mutableContainers)
        serialiser.acceptableContentTypes = Set(["application/json", "text/html"])
        manager.responseSerializer = serialiser
        return manager
    }()
    
    enum TimeFrameType: String {
        case today = "Today"
        case past = "Past"
        case future = "Future"
    }
    
    var url = "http://prestigemotorsport.com.au/wp-admin/admin-ajax.php"
    
    func fetchNSXAuctionRecords(timeFrameType: TimeFrameType, offset: Int, manualOnly: Bool, success: ((Int, [NSXEntry]?) -> ())?, failure: ((Error?) -> ())?) -> URLSessionTask {
        let headers = [
            "Pragma": "no-cache",
            "Cache-Control": "no-cache",
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36",
            "Content-Type": "application/x-www-form-urlencoded",
            "X-Requested-With": "XMLHttpRequest",
            "Accept": "application/json"
        ]
        
        
        let request = AFJSONRequestSerializer(writingOptions: .prettyPrinted).request(withMethod: "POST", urlString: url, parameters: nil, error: nil)
        
        // Apply headers
        for (key, val) in headers {
            request.addValue(val, forHTTPHeaderField: key)
        }
        
        var fields = [
            "action": "search_results_car_dev",
            "limit_start": "\(offset)",
            "auction-date": timeFrameType.rawValue,
            "marka_id": "5",
            "model_id": "604",
            "year_from": "1989",
            "year_to": "2008",
        ]
        if manualOnly {
            fields["transmissions"] = "Manual"
        }
        
        let queryString = makeQueryString(with: fields)
        request.httpBody = queryString.data(using: .utf8)
        
        
        let dataTask = manager.dataTask(with: request as URLRequest, completionHandler: { (response, responseObject, error) in
            if let error = error {
                debugPrint("error = \(error)")
                if let failure = failure {
                    failure(error)
                }
            } else {
                if let json = responseObject as? [AnyHashable: Any] {
                    var total = 0
                    if let jsontotal = json["total"] as? Int {
                        print("total = \(total)")
                        total = jsontotal
                    } else if let totalString = json["total"] as? String, let jsontotal = Int(totalString) {
                        print("wtf man total is string: \(jsontotal)")
                        total = jsontotal
                    }
                    
                    if total > 0, let carsHtml = json["cars_html"] as? String {
                        let parser = HTMLParser(string: carsHtml)
                        let context = HTMLElement(tagName: "jas-car-item")
                        
                        let nodes = parser.parseFragment(withContextElement: context)
                        
                        var entries = [NSXEntry]()
                        for node in nodes {
                            let entry = NSXEntry()
                            entry.load(with: node)
                            entries.append(entry)
                        }
                        debugPrint("End of process")
                        if let success = success {
                            success(total, entries)
                        }
                    } else {
                        if let success = success {
                            success(0, nil)
                        }
                    }
                }
            }
        })
        
        dataTask.resume()
        return dataTask
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
