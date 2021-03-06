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
    
    var lastLoadDates = [WatcherAPI.TimeFrameType: Date]()
    
    var selectedSearchTimeFrame: WatcherAPI.TimeFrameType = .future
    
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
    
    var entriesForSelectedSection: [NSXEntry] {
        guard let results = entries[selectedSearchTimeFrame] else {
            return [NSXEntry]()
        }
        return results
    }
    
    var activeTasks = Set<URLSessionTask>()
}


// MARK: - View Model display logic
extension NSXAuctionListingsViewModel {
    var lastFetchedDateDisplayString: String {
        guard let date = lastLoadDates[selectedSearchTimeFrame] else {
            return "Didn't get the last fetched date."
        }
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:mma"
        df.timeZone = NSTimeZone.local
        
        return "Last fetched: \(df.string(from: date))"
    }
}


// MARK: - API call methods
extension NSXAuctionListingsViewModel {
    /**
     Reload entries for a particular timeFrame.
    */
    func reloadSection(completion: ((Date?) -> ())?) {
        let section = selectedSearchTimeFrame
        fetchRecords(ofType: section, inventory: [NSXEntry]()) { (results: [NSXEntry]) in
            self.entries[section]!.removeAll()
            self.entries[section]!.append(contentsOf: results.sorted(by: {
                return $0.auctionDate > $1.auctionDate
            }))
            
            if self.activeTasks.filter({ task -> Bool in
                return task.state != .completed
            }).isEmpty, let completion = completion {
                let now = Date()
                self.lastLoadDates[self.selectedSearchTimeFrame] = now
                completion(now)
            }
        }
    }
    
    /**
     Reload entries for all available timeFrame.
     */
    func reloadAll(completion: ((Date?) -> ())?) {
        for section in sections {
            fetchRecords(ofType: section, inventory: [NSXEntry]()) { (results: [NSXEntry]) in
                self.entries[section]!.removeAll()
                self.entries[section]!.append(contentsOf: results.sorted(by: {
                    return $0.auctionDate > $1.auctionDate
                }))
                
                if self.activeTasks.filter({ task -> Bool in
                    return task.state != .completed
                }).isEmpty, let completion = completion {
                    let now = Date()
                    self.lastLoadDates[self.selectedSearchTimeFrame] = now
                    completion(now)
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
}
