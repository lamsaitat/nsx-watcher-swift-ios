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
    
    var entriesLoaded: [WatcherAPI.TimeFrameType: Int] = [
        .future: 0,
        .today: 0,
        .past: 0
    ]
    
    lazy var entryCellViewModels: [WatcherAPI.TimeFrameType: [NSXAuctionListingCellViewModel]] = {
        var vms = [WatcherAPI.TimeFrameType: [NSXAuctionListingCellViewModel]]()
        for section in self.sections {
            vms[section] = [NSXAuctionListingCellViewModel]()
        }
        return vms
    }()
    
    var entryCellViewModelsForSelectedSection: [NSXAuctionListingCellViewModel] {
        guard let results = entryCellViewModels[selectedSearchTimeFrame] else {
            return [NSXAuctionListingCellViewModel]()
        }
        return results
    }
    
    func canLoadMore(section: WatcherAPI.TimeFrameType) -> Bool {
        return entryCellViewModels[section]!.count < entriesLoaded[section]!
    }
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
    
    private func process(_ entries: [Listing], forSection section: WatcherAPI.TimeFrameType, shouldRemoveExisting: Bool) {
        if shouldRemoveExisting {
            entryCellViewModels[section]!.removeAll()
        }
        
        let sorted = entries.sorted(by: {
            return $0.auctionDate > $1.auctionDate
        })
        
        for entry in sorted {
            let vm = NSXAuctionListingCellViewModel(entry)
            entryCellViewModels[section]!.append(vm)
        }
    }
    /**
     Reload entries for a particular timeFrame.
    */
    func reloadSection(completion: ((Date?) -> ())?) {
        let section = selectedSearchTimeFrame
        fetchRecords(ofType: section, offset: 0) { (results: [Listing]) in
            self.process(results, forSection: section, shouldRemoveExisting: true)
            
            if let completion = completion {
                let now = Date()
                self.lastLoadDates[self.selectedSearchTimeFrame] = now
                completion(now)
            }
        }
    }
    
    func loadMore(completion: ((Date?) -> ())?) {
        let section = selectedSearchTimeFrame
        fetchRecords(ofType: section, offset: entryCellViewModels[section]!.count) { (results: [Listing]) in
            self.process(results, forSection: section, shouldRemoveExisting: false)
            
            if let completion = completion {
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
            fetchRecords(ofType: section, offset: 0) { (results: [Listing]) in
                self.process(results, forSection: section, shouldRemoveExisting: true)
                
                if let completion = completion {
                    let now = Date()
                    self.lastLoadDates[self.selectedSearchTimeFrame] = now
                    completion(now)
                }
            }
        }
    }
    
    
    /**
     * Allows for paginated fetch.
     */
    func fetchRecords(ofType timeFrameType: WatcherAPI.TimeFrameType, offset: Int, completion: (([Listing]) -> ())?) {
        
        _ = api.fetchNSXAuctionRecords(timeFrameType: timeFrameType, offset: offset, manualOnly: true, success: { (total: Int, entries: [Listing]?) in
            self.entriesLoaded[timeFrameType] = total
            if let completion = completion {
                completion(entries!)
            }
        }, failure: nil)
    }
}
