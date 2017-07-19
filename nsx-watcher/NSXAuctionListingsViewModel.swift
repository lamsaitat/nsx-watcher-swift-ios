//
//  NSXAuctionListingsViewModel.swift
//  nsx-watcher
//
//  Created by Sai Tat Lam on 19/7/17.
//  Copyright © 2017 Henshin Soft Pty Ltd. All rights reserved.
//

import UIKit

class NSXAuctionListingsViewModel {
    
    let api = WatcherAPI()
    
    let sections: [WatcherAPI.TimeFrameType] = [
        .future,
        .today,
        .past
    ]
    
    lazy var entries: [WatcherAPI.TimeFrameType: [NSXEntry]] = {
        var entries = Dictionary<WatcherAPI.TimeFrameType, [NSXEntry]>()
        for section in self.sections {
            entries[section] = [NSXEntry]()
        }
        return entries
    }()
    
    var activeTasks = Set<URLSessionTask>()
    
    func reloadAll(completion: (() -> ())?) {
        for section in sections {
            fetchRecords(ofType: section, inventory: [NSXEntry]()) { (results: [NSXEntry]) in
                self.entries[section]!.removeAll()
                self.entries[section]!.append(contentsOf: results.sorted(by: { (lhs, rhs) -> Bool in
                    let lhsDate = lhs.auctionDate! as Date
                    let rhsDate = rhs.auctionDate! as Date
                    return lhsDate > rhsDate
                }))
                
                if self.activeTasks.filter({ task -> Bool in
                    return task.state != .completed
                }).isEmpty, let completion = completion {
                    completion()
                }
            }
        }
    }
    
    func fetchRecords(ofType timeFrameType: WatcherAPI.TimeFrameType, inventory: [NSXEntry], completion: (([NSXEntry]) -> ())?) {
        var fetchedEntries = inventory
        let task = api.fetchNSXAuctionRecords(timeFrameType: timeFrameType, offset: fetchedEntries.count, manualOnly: true, success: { (total: Int, entries: [NSXEntry]?) in
            
            if let entries = entries {
                fetchedEntries.append(contentsOf: entries)
            }
            if fetchedEntries.count < total {
                self.fetchRecords(ofType: timeFrameType, inventory: fetchedEntries, completion: completion)
            } else if let completion = completion {
                completion(fetchedEntries)
            }
        }, failure: nil)
        activeTasks.insert(task)
    }
    
    
    lazy var auctionDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = NSXEntry.auctionDateFormat
        return dateFormatter
    }()
    
    func configure(cell: NSXAuctionListingCell, entry: NSXEntry) {
        cell.titleLabel.text = entry.title
        cell.conditionGradeLabel.text = entry.gradeString
        if let imageUrlString = entry.imageUrl, let imageUrl = URL(string: imageUrlString) {
            cell.carImageView.setImageWith(imageUrl, placeholderImage: UIImage(named: "loading"))
        } else {
            cell.carImageView.image = nil
        }
        
        if let auctionDate = entry.auctionDate {
            cell.auctionDateLabel.text = "Auction Date: \(auctionDateFormatter.string(from: auctionDate as Date))"
        } else {
            cell.auctionDateLabel.text = "Auction Date: N/A"
        }
        
        cell.startingBidLabel.text = entry.auctionPriceString
    }
}
