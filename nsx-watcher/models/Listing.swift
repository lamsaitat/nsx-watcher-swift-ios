//
//  Listing.swift
//  nsx-watcher
//
//  Created by Kelvin Lam on 17/7/17.
//  Copyright © 2017 Henshin Soft Pty Ltd. All rights reserved.
//

import Foundation
import HTMLKit


struct Listing {
    static let auctionDateFormat = "dd-MM-yyyy"
    
    let auctionLocation: String
    let auctionPriceString: String
    let detailPageUrlString: String
    let auctionDate: Date
    
    let carId: String?
    let title: String?
    
    // These are for filtering purposes.
    let displacement: String?
    let gradeString: String?
    let imageUrl: String?
    let mileage: String?
    let transmission: String?
    
    fileprivate let htmlBody: String  // For debug purposes.
    
    var url: URL? {
        return URL(string: detailPageUrlString)
    }
}


extension Listing {
    init?(with dictionary: [AnyHashable: Any]) {
        guard let htmlBody = dictionary["htmlBody"] as? String,
            let auctionDate = dictionary["auctionDate"] as? Date,
            let auctionLocation = dictionary["auctionLocation"] as? String,
            let auctionPriceString = dictionary["auctionPriceString"] as? String,
            let detailPageUrl = dictionary["detailPageUrl"] as? String
            else {
                return nil
        }
        self.htmlBody = htmlBody
        self.auctionDate = auctionDate
        self.auctionLocation = auctionLocation
        self.auctionPriceString = auctionPriceString
        self.detailPageUrlString = detailPageUrl
        
        carId = dictionary["carId"] as? String
        title = dictionary["title"] as? String
        displacement = dictionary["displacement"] as? String
        gradeString = dictionary["gradeString"] as? String
        imageUrl = dictionary["imageUrl"] as? String
        mileage = dictionary["mileage"] as? String
        transmission = dictionary["transmission"] as? String
    }
}
