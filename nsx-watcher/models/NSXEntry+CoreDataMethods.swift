//
//  NSXEntry+CoreDataMethods.swift
//  nsx-watcher
//
//  Created by Kelvin Lam on 17/7/17.
//  Copyright © 2017 Henshin Soft Pty Ltd. All rights reserved.
//

import Foundation
import HTMLKit

extension NSXEntry {
    
    static let auctionDateFormat = "dd-MM-yyyy"
    
    func load(with htmlNode: HTMLNode) {
        htmlBody = htmlNode.outerHTML
        
        let childNodes = htmlNode.childNodes.array as! [HTMLElement]
        
        let contentNode = childNodes.filter({ elem -> Bool in
            return elem.className == "jas-car-item-content"
        }).first!
        
        let auctionDateNode = (contentNode.childNodes.array as! [HTMLElement]).filter({ (elem: HTMLElement) -> Bool in
            return elem.className == "jas-auction-date" && elem.outerHTML.contains("Auction Date")
        }).first!
        let auctionDateSpanString = (auctionDateNode.childNodes.lastObject as! HTMLElement).innerHTML
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = NSXEntry.auctionDateFormat
        auctionDate = dateFormatter.date(from: auctionDateSpanString) as NSDate?
        
        
        let priceNode = childNodes.filter({ elem -> Bool in
            return elem.className == "jas-price"
        }).first!.firstChild!
        let priceTag = (priceNode.childNodes.array  as! [HTMLElement]).filter({ (elem: HTMLElement) -> Bool in
            return elem.tagName == "h6"
        }).first!
        auctionPriceString = priceTag.innerHTML
    }

}
