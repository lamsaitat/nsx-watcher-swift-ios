//
//  NSXAuctionListingCell.swift
//  nsx-watcher
//
//  Created by Sai Tat Lam on 19/7/17.
//  Copyright © 2017 Henshin Soft Pty Ltd. All rights reserved.
//

import UIKit

class NSXAuctionListingCell: UITableViewCell {
    static let reuseIdentifier = "NSXAuctionListingCell"
    
    @IBOutlet var carImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var conditionGradeLabel: UILabel!
    @IBOutlet var auctionDateLabel: UILabel!
    @IBOutlet var startingBidLabel: UILabel!
    
    lazy var placeholderImage: UIImage = {
        return UIImage(named: "loading")!
    }()
}
