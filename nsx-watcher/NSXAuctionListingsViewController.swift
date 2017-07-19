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
    
    var viewModel = NSXAuctionListingsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(hardReload), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        hardReload()
    }
    
    func hardReload() {
        ARSLineProgress.show()
        viewModel.reloadAll(completion: {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd hh:mma"
            df.timeZone = NSTimeZone.local
            self.title = "Last fetched: \(df.string(from: Date()))"
            
            DispatchQueue.main.async {
                ARSLineProgress.hide()
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.entries[viewModel.sections[section]]!.count
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NSXAuctionListingCell", for: indexPath) as! NSXAuctionListingCell
        let entry = viewModel.entries[viewModel.sections[indexPath.section]]![indexPath.row]
        
        viewModel.configure(cell: cell, entry: entry)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section < viewModel.sections.count else {
            return nil
        }
        
        return viewModel.sections[section].rawValue
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "CellSelectionSegue", let cell = sender as? NSXAuctionListingCell {
            if let indexPath = tableView.indexPath(for: cell), let vc = segue.destination as? WebViewController {
                let entry = viewModel.entries[viewModel.sections[indexPath.section]]![indexPath.row]
                vc.entry = entry
            }
        }
    }
}
