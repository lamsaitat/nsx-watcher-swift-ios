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
    
    var entries: [WatcherAPI.TimeFrameType: [NSXEntry]] = [
        WatcherAPI.TimeFrameType.future: [NSXEntry](),
        WatcherAPI.TimeFrameType.today: [NSXEntry](),
        WatcherAPI.TimeFrameType.past: [NSXEntry]()
    ]
    
    func reloadAll(completion: (() -> ())?) {
        var allEntriesTotals = [
            false,
            false,
            false
        ]
        
        fetchFutureRecords(inventory: [NSXEntry]()) { (results: [NSXEntry]) in
            allEntriesTotals[0] = true
            self.entries[.future]!.removeAll()
            self.entries[.future]!.append(contentsOf: results.sorted(by: { (lhs, rhs) -> Bool in
                let lhsDate = lhs.auctionDate! as Date
                let rhsDate = rhs.auctionDate! as Date
                return lhsDate > rhsDate
            }))
            
            if allEntriesTotals.filter({ (elem) -> Bool in
                return elem == false
            }).isEmpty, let completion = completion {
                completion()
            }
        }
        
        fetchTodayRecords(inventory: [NSXEntry]()) { (results: [NSXEntry]) in
            allEntriesTotals[1] = true
            self.entries[.today]!.removeAll()
            self.entries[.today]!.append(contentsOf: results.sorted(by: { (lhs, rhs) -> Bool in
                let lhsDate = lhs.auctionDate! as Date
                let rhsDate = rhs.auctionDate! as Date
                return lhsDate > rhsDate
            }))
            
            if allEntriesTotals.filter({ (elem) -> Bool in
                return elem == false
            }).isEmpty, let completion = completion {
                completion()
            }
        }
        
        fetchPastRecords(inventory: [NSXEntry]()) { (results: [NSXEntry]) in
            allEntriesTotals[2] = true
            self.entries[.past]!.removeAll()
            self.entries[.past]!.append(contentsOf: results.sorted(by: { (lhs, rhs) -> Bool in
                let lhsDate = lhs.auctionDate! as Date
                let rhsDate = rhs.auctionDate! as Date
                return lhsDate > rhsDate
            }))
            
            if allEntriesTotals.filter({ (elem) -> Bool in
                return elem == false
            }).isEmpty, let completion = completion {
                completion()
            }
        }
    }
    
    func fetchFutureRecords(inventory: [NSXEntry], completion: (([NSXEntry]) -> ())?) {
        var fetchedEntries = inventory
        api.fetchNSXAuctionRecords(timeFrameType: .future, offset: fetchedEntries.count, manualOnly: true, success: { (total: Int, entries: [NSXEntry]?) in
            
            if let entries = entries {
                fetchedEntries.append(contentsOf: entries)
            }
            if fetchedEntries.count < total {
                self.fetchFutureRecords(inventory: fetchedEntries, completion: completion)
            } else if let completion = completion {
                completion(fetchedEntries)
            }
        }, failure: nil)
    }
    
    func fetchTodayRecords(inventory: [NSXEntry], completion: (([NSXEntry]) -> ())?) {
        var fetchedEntries = inventory
        api.fetchNSXAuctionRecords(timeFrameType: .today, offset: fetchedEntries.count, manualOnly: true, success: { (total: Int, entries: [NSXEntry]?) in
            
            if let entries = entries {
                fetchedEntries.append(contentsOf: entries)
            }
            if fetchedEntries.count < total {
                self.fetchTodayRecords(inventory: fetchedEntries, completion: completion)
            } else if let completion = completion {
                completion(fetchedEntries)
            }
        }, failure: nil)
    }
    
    func fetchPastRecords(inventory: [NSXEntry], completion: (([NSXEntry]) -> ())?) {
        var fetchedEntries = inventory
        api.fetchNSXAuctionRecords(timeFrameType: .past, offset: fetchedEntries.count, manualOnly: true, success: { (total: Int, entries: [NSXEntry]?) in
            
            if let entries = entries {
                fetchedEntries.append(contentsOf: entries)
            }
            if fetchedEntries.count < total {
                self.fetchPastRecords(inventory: fetchedEntries, completion: completion)
            } else if let completion = completion {
                completion(fetchedEntries)
            }
        }, failure: nil)
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
