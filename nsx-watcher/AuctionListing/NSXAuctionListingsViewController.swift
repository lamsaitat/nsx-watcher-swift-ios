//
//  NSXAuctionListingsViewController.swift
//  nsx-watcher
//
//  Created by Kelvin Lam on 18/7/17.
//  Copyright © 2017 Henshin Soft Pty Ltd. All rights reserved.
//

import UIKit
import ARSLineProgress
import RxSwift
import RxCocoa

class NSXAuctionListingsViewController: UITableViewController {
    
    @IBOutlet var searchDateRangeSegmentedControl: UISegmentedControl!
    @IBOutlet var lastFetchedTimeStampLabel: UILabel!
    
    var viewModel = NSXAuctionListingsViewModel()
    var disposeBag = DisposeBag()
    var listings = BehaviorRelay(value: [NSXAuctionListingCellViewModel]())

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = nil
        tableView.delegate = nil
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableView.automaticDimension
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(hardReload), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        listings.asObservable().bind(to: tableView.rx.items(cellIdentifier: NSXAuctionListingCell.reuseIdentifier, cellType: NSXAuctionListingCell.self)) {
            (row, vm, cell) in
            cell.titleLabel.text = vm.titleDisplayString
            cell.conditionGradeLabel.text = vm.conditionGradeDisplayString
            cell.auctionDateLabel.text = vm.auctionDateDisplayString
            cell.startingBidLabel.text = vm.startingBidDisplayString
            
            if let url = vm.imageURL {
                cell.carImageView.setImageWith(url, placeholderImage: cell.placeholderImage)
            } else {
                cell.carImageView.image = cell.placeholderImage
            }
        }.disposed(by: disposeBag)
        
        tableView.rx.willDisplayCell.subscribe(onNext: { cell, indexPath in
            if indexPath.row == self.viewModel.entryCellViewModelsForSelectedSection.count - 1 && self.viewModel.canLoadMore(section: self.viewModel.selectedSearchTimeFrame) {
                self.loadMore()
            }
        }).disposed(by: disposeBag)
        
        hardReload()
    }
    
    @objc func hardReload() {
        ARSLineProgress.show()
        lastFetchedTimeStampLabel.text = "Loading..."
        viewModel.reloadSection(completion: { lastLoadedDate in
            DispatchQueue.main.async {
                ARSLineProgress.hide()
                self.tableView.refreshControl?.endRefreshing()
                self.lastFetchedTimeStampLabel.text = self.viewModel.lastFetchedDateDisplayString

                self.tableReload()
            }
        })
    }
    
    @objc func loadMore() {
        guard viewModel.canLoadMore(section: viewModel.selectedSearchTimeFrame) else {
            return
        }
        
        ARSLineProgress.show()
        lastFetchedTimeStampLabel.text = "Loading more..."
        
        viewModel.loadMore(completion: { lastLoadedDate in
            DispatchQueue.main.async {
                ARSLineProgress.hide()
                self.tableView.refreshControl?.endRefreshing()
                self.lastFetchedTimeStampLabel.text = self.viewModel.lastFetchedDateDisplayString
                
                self.tableReload()
            }
        })
    }
    
    func tableReload() {
        listings.accept(viewModel.entryCellViewModelsForSelectedSection)
    }
    
    // MARK: - IBActions
    
    @IBAction func searchDateRangeSegmentedControlValueChanged(_ sender: Any?) {
        viewModel.selectedSearchTimeFrame = viewModel.sections[searchDateRangeSegmentedControl.selectedSegmentIndex]
        
        let now = Date()
        if let lastLoadDate = viewModel.lastLoadDates[viewModel.selectedSearchTimeFrame], now.timeIntervalSince(lastLoadDate) < 60 * 10 {   // Less than 10 mins just display...
            ARSLineProgress.hide()
            tableView.refreshControl?.endRefreshing()
            lastFetchedTimeStampLabel.text = viewModel.lastFetchedDateDisplayString
            tableReload()
        } else {
            hardReload()
        }
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "CellSelectionSegue", let cell = sender as? NSXAuctionListingCell {
            if let indexPath = tableView.indexPath(for: cell), let vc = segue.destination as? WebViewController {
                let entry = viewModel.entryCellViewModelsForSelectedSection[indexPath.row].entry
                vc.entry = entry
            }
        }
    }
}
