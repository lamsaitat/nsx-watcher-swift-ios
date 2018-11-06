//
//  NSXAuctionListingViewModel.swift
//  nsx-watcher
//
//  Created by Sai Tat Lam on 6/11/18.
//  Copyright © 2018 Henshin Soft Pty Ltd. All rights reserved.
//

import UIKit

class NSXAuctionListingCellViewModel {
    let entry: NSXEntry
    
    required init(_ entry: NSXEntry) {
        self.entry = entry
    }
    
    lazy var auctionDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = NSXEntry.auctionDateFormat
        return df
    }()
}

extension NSXAuctionListingCellViewModel {
    var titleDisplayString: String {
        return entry.title ?? "Unknown model"
    }
    
    var conditionGradeDisplayString: String {
        return entry.gradeString ?? "Unknown grade"
    }
    
    var imageURL: URL? {
        guard let imageUrlString = entry.imageUrl else {
            return nil
        }
        return URL(string: imageUrlString)
    }
    
    var auctionDateDisplayString: String {
        return "Auction Date: \(auctionDateFormatter.string(from: entry.auctionDate))"
    }
    
    var startingBidDisplayString: String {
        return entry.auctionPriceString
    }
}
