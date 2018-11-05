//
//  NSXEntry+CoreDataMethods.swift
//  nsx-watcher
//
//  Created by Kelvin Lam on 17/7/17.
//  Copyright © 2017 Henshin Soft Pty Ltd. All rights reserved.
//

import Foundation
import HTMLKit


struct NSXEntry {
    var auctionDate: NSDate?
    var auctionLocation: String?
    var auctionPriceString: String?
    var carId: String?
    var dateAdded: NSDate?
    var dateModified: NSDate?
    var detailPageUrl: String?
    var displacement: String?
    var gradeString: String?
    var imageUrl: String?
    var mileage: String?
    var title: String?
    var transmission: String?
    var htmlBody: String?
}


extension NSXEntry {
    
    static let auctionDateFormat = "dd-MM-yyyy"

    init?(with htmlNode: HTMLNode) {
        htmlBody = htmlNode.outerHTML
        guard let childNodes = htmlNode.childNodes.array as? [HTMLElement] else {
            debugPrint("Child nodes not available, not parsing.")
            return nil
        }
        
        for htmlChild in childNodes {
            if htmlChild.className == "jas-car-item-content" {
                let contentNode = htmlChild
                
                for contentChildNode in contentNode.childNodes.array as! [HTMLElement] {
                    if contentChildNode.className == "jas-auction-date" {
                        if contentChildNode.outerHTML.contains("Auction Date"), let endNode = contentChildNode.childNodes.lastObject as? HTMLElement {
                            let auctionDateSpanString = endNode.textContent.trimWhitespaces()
                            
                            // Auction date
                            if auctionDateSpanString.lowercased().contains("today") {
                                auctionDate = NSDate()
                            } else {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = NSXEntry.auctionDateFormat
                                auctionDate = dateFormatter.date(from: auctionDateSpanString) as NSDate?
                            }
                        } else {
                            // Auction location
                            auctionLocation = contentChildNode.innerHTML
                        }
                    } else if contentChildNode.tagName == "ul", let nodes = contentChildNode.childNodes.array as? [HTMLElement] {
                        for (idx, li) in nodes.enumerated() {
                            let content = li.textContent.trimWhitespaces()
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
                    } else if contentChildNode.tagName == "a" {
                        if let href = contentChildNode.attributes["href"] as? String {
                            detailPageUrl = href
                        }
                    } else if contentChildNode.tagName == "h5" {
                        title = contentChildNode.textContent.trimWhitespaces()
                    }
                }
            } else if htmlChild.className == "jas-price", let priceNode = htmlChild.firstChild, let nodes = priceNode.childNodes.array as? [HTMLElement] {
                for node in nodes {
                    if node.tagName == "a", let href = node.attributes["href"] as? String {
                        detailPageUrl = href
                    } else if node.tagName == "h6" {
                        auctionPriceString = node.textContent.trimWhitespaces()
                    }
                }
            } else if htmlChild.tagName == "a", let imgChild = htmlChild.firstChild as? HTMLElement, let imgUrl = imgChild.attributes["src"] as? String {
                imageUrl = imgUrl
                
                if let href = htmlChild.attributes["href"] as? String, let urlComponents = URLComponents(string: href), let queryDict = urlComponents.queryDictionary, let uid = queryDict["car_id"] as? String {
                    detailPageUrl = href
                    carId = uid
                }
            }
        }
    }
}


fileprivate extension String {
    func trimWhitespaces() -> String {
        return replacingOccurrences(of: "^\\s+", with: "", options: .regularExpression).replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression).replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
}
