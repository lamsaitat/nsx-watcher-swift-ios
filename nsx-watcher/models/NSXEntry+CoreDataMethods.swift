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
        
        for htmlChild in childNodes {
            if htmlChild.className == "jas-car-item-content" {
                let contentNode = htmlChild
                
                for contentChildNode in contentNode.childNodes.array as! [HTMLElement] {
                    if contentChildNode.className == "jas-auction-date" {
                        if contentChildNode.outerHTML.contains("Auction Date") {
                            // Auction date
                            let auctionDateSpanString = (contentChildNode.childNodes.lastObject as! HTMLElement).innerHTML
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = NSXEntry.auctionDateFormat
                            auctionDate = dateFormatter.date(from: auctionDateSpanString) as NSDate?
                        } else {
                            // Auction location
                            auctionLocation = contentChildNode.innerHTML
                        }
                    } else if contentChildNode.tagName == "ul" {
                        for (idx, li) in (contentChildNode.childNodes.array as! [HTMLElement]).enumerated() {
                            if let content = type(of: self).trimWhitespaces(li.textContent) {
                                if idx == 0 || content.hasSuffix("cc") {
                                    displacement = content
                                } else if idx == 1 {
                                    transmission = content
                                } else if idx == 2 {
                                    mileage = content
                                } else if idx == 3 {
                                    gradeString = content
                                }
                            }
                        }
                    } else if contentChildNode.tagName == "a" {
                        if let href = contentChildNode.attributes["href"] as? String {
                            detailPageUrl = href
                        }
                    } else if contentChildNode.tagName == "h5" {
                        title = type(of: self).trimWhitespaces(contentChildNode.textContent)
                    }
                }
            } else if htmlChild.tagName == "a", let imgChild = htmlChild.firstChild as? HTMLElement, let imgUrl = imgChild.attributes["src"] as? String {
                imageUrl = imgUrl
                
                if let href = htmlChild.attributes["href"] as? String, let urlComponents = URLComponents(string: href), let queryDict = urlComponents.queryDictionary, let uid = queryDict["car_id"] as? String {
                    carId = uid
                }
            }
        }
        
        
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
    
    static func trimWhitespaces(_ inString: String?) -> String? {
        guard let input = inString else {
            return nil
        }
        
        return input.replacingOccurrences(of: "^\\s+", with: "", options: .regularExpression).replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression).replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }

}
