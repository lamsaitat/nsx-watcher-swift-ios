//
//  NSXAuctionListingsViewController.swift
//  nsx-watcher
//
//  Created by Kelvin Lam on 18/7/17.
//  Copyright © 2017 Henshin Soft Pty Ltd. All rights reserved.
//

import UIKit
import ARSLineProgress

class NSXAuctionListingsViewController: UITableViewController {
    
    @IBOutlet var searchDateRangeSegmentedControl: UISegmentedControl!
    @IBOutlet var lastFetchedTimeStampLabel: UILabel!
    
    var viewModel = NSXAuctionListingsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableView.automaticDimension
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(hardReload), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        hardReload()
    }
    
    @objc func hardReload() {
        ARSLineProgress.show()
        lastFetchedTimeStampLabel.text = "Loading..."
//        viewModel.reloadAll(completion: { lastLoadedDate in
        viewModel.reloadSection(completion: { lastLoadedDate in
//            let df = DateFormatter()
//            df.dateFormat = "yyyy-MM-dd hh:mma"
//            df.timeZone = NSTimeZone.local
//            if let date = lastLoadedDate {
//                self.lastFetchedTimeStampLabel.text = "Last fetched: \(df.string(from: date))"
//            } else {
//                self.lastFetchedTimeStampLabel.text = "Didn't get the last fetched date."
//            }
            
            DispatchQueue.main.async {
                ARSLineProgress.hide()
                self.tableView.refreshControl?.endRefreshing()
                self.lastFetchedTimeStampLabel.text = self.viewModel.lastFetchedDateDisplayString
                self.tableView.reloadData()
            }
        })
    }
    
    // MARK: - IBActions
    
    @IBAction func searchDateRangeSegmentedControlValueChanged(_ sender: Any?) {
        viewModel.selectedSearchTimeFrame = viewModel.sections[searchDateRangeSegmentedControl.selectedSegmentIndex]
        
        let now = Date()
        if let lastLoadDate = viewModel.lastLoadDates[viewModel.selectedSearchTimeFrame], now.timeIntervalSince(lastLoadDate) < 60 * 10 {   // Less than 10 mins just display...
            ARSLineProgress.hide()
            tableView.refreshControl?.endRefreshing()
            lastFetchedTimeStampLabel.text = viewModel.lastFetchedDateDisplayString
            tableView.reloadData()
        } else {
            hardReload()
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.entriesForSelectedSection.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NSXAuctionListingCell", for: indexPath) as! NSXAuctionListingCell
        let entry = viewModel.entriesForSelectedSection[indexPath.row]
        
        viewModel.configure(cell: cell, entry: entry)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section < viewModel.sections.count else {
            return nil
        }
        
        return viewModel.selectedSearchTimeFrame.rawValue
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "CellSelectionSegue", let cell = sender as? NSXAuctionListingCell {
            if let indexPath = tableView.indexPath(for: cell), let vc = segue.destination as? WebViewController {
                let entry = viewModel.entriesForSelectedSection[indexPath.row]
                vc.entry = entry
            }
        }
    }
}
