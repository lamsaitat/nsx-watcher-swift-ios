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
                        if contentChildNode.outerHTML.contains("Auction Date"), let auctionDateSpanString = type(of: self).trimWhitespaces((contentChildNode.childNodes.lastObject as! HTMLElement).textContent) {
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
            } else if htmlChild.className == "jas-price", let priceNode = htmlChild.firstChild {
                for node in priceNode.childNodes.array as! [HTMLElement] {
                    if node.tagName == "a", let href = node.attributes["href"] as? String {
                        detailPageUrl = href
                    } else if node.tagName == "h6" {
                        auctionPriceString = type(of: self).trimWhitespaces(node.textContent)
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
    
    static func trimWhitespaces(_ inString: String?) -> String? {
        guard let input = inString else {
            return nil
        }
        
        return input.replacingOccurrences(of: "^\\s+", with: "", options: .regularExpression).replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression).replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }

}
