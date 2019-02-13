//
//  WatcherAPI.swift
//  nsx-watcher
//
//  Created by Kelvin Lam on 17/7/17.
//  Copyright © 2017 Henshin Soft Pty Ltd. All rights reserved.
//

import UIKit
import Alamofire
import HTMLKit

class WatcherAPI {

    enum TimeFrameType: String {
        case today = "Today"
        case past = "Past"
        case future = "Future"
    }
    
    enum CarModelId: String {
        case nsx = "604"
        case civic = "567"
    }
    
    let url = "http://prestigemotorsport.com.au/wp-admin/admin-ajax.php"
    let headers = [
        "Pragma": "no-cache",
        "Cache-Control": "no-cache",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36",
        "Content-Type": "application/x-www-form-urlencoded",
        "X-Requested-With": "XMLHttpRequest",
        "Accept": "application/json"
    ]
    
    
    func fetchNSXAuctionRecords(timeFrameType: TimeFrameType, offset: Int, manualOnly: Bool, success: ((Int, [NSXEntry]?) -> ())?, failure: ((Error?) -> ())?) {
        var fields = [
            "action": "search_results_car_dev",
            "limit_start": "\(offset)",
            "auction-date": timeFrameType.rawValue,
            "marka_id": "5",
            "model_id": CarModelId.civic.rawValue,
            "year_from": "1989",
            "year_to": "2011",
            ]
        if manualOnly {
            fields["transmissions"] = "Manual"
        }
        
        Alamofire.request(url, method: .post, parameters: fields, encoding: URLEncoding.httpBody, headers: headers).responseJSON { response in
            
            if let error = response.error {
                debugPrint("error = \(error)")
                if let failure = failure {
                    failure(error)
                }
            } else if let json = response.result.value as? [AnyHashable: Any] {
                var total = 0
                if let jsontotal = json["total"] as? Int {
                    total = jsontotal
                } else if let totalString = json["total"] as? String, let jsontotal = Int(totalString) {
                    total = jsontotal
                }

                var entries = [NSXEntry]()
                if total > 0, let carsHtml = json["cars_html"] as? String {
                    let dicts = HTMLNodeParser.dictionaries(from: carsHtml)

                    for dictionary in dicts {
                        if let entry = NSXEntry(with: dictionary) {
                            entries.append(entry)
                        }
                    }
                }
                if let success = success {
                    success(total, entries)
                }
            }
        }
    }
}
