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
    static let auctionDateFormat = "dd-MM-yyyy"
    
    let auctionLocation: String
    let auctionPriceString: String
    let detailPageUrlString: String
    let auctionDate: Date
    
    let carId: String?
    let title: String?
    let displacement: String?
    let gradeString: String?
    let imageUrl: String?
    let mileage: String?
    let transmission: String?
    
    fileprivate let htmlBody: String  // For debug purposes.
    
    var url: URL? {
        return URL(string: detailPageUrlString)
    }
}


extension NSXEntry {
    init?(with htmlNode: HTMLNode) {
        
        guard let dictionary = Parser.dictionary(from: htmlNode),
            let auctionDate = dictionary["auctionDate"] as? Date,
            let auctionLocation = dictionary["auctionLocation"] as? String,
            let auctionPriceString = dictionary["auctionPriceString"] as? String,
            let detailPageUrl = dictionary["detailPageUrl"] as? String
            else {
            return nil
        }
        htmlBody = htmlNode.outerHTML
        
        self.auctionDate = auctionDate
        self.auctionLocation = auctionLocation
        self.auctionPriceString = auctionPriceString
        self.detailPageUrlString = detailPageUrl
        
        carId = dictionary["carId"] as? String
        title = dictionary["title"] as? String
        displacement = dictionary["displacement"] as? String
        gradeString = dictionary["gradeString"] as? String
        imageUrl = dictionary["imageUrl"] as? String
        mileage = dictionary["mileage"] as? String
        transmission = dictionary["transmission"] as? String
    }
}

fileprivate extension NSXEntry {
    class Parser {
        
        static func dictionary(from htmlNode: HTMLNode) -> [AnyHashable: Any]? {
            var dictionary = [AnyHashable: Any]()
            guard let childNodes = htmlNode.childNodes.array as? [HTMLElement] else {
                debugPrint("Child nodes not available, not parsing.")
                return dictionary
            }
            
            for htmlChild in childNodes {
                if htmlChild.className == "jas-car-item-content", let contentChildNodes = htmlChild.childNodes.array as? [HTMLElement] {
                    
                    for contentChildNode in contentChildNodes {
                        if contentChildNode.className == "jas-auction-date" {
                            if contentChildNode.outerHTML.contains("Auction Date"), let endNode = contentChildNode.childNodes.lastObject as? HTMLElement {
                                let auctionDateSpanString = endNode.textContent.trimWhitespaces()
                                // Auction date
                                if auctionDateSpanString.lowercased().contains("today") {
                                    dictionary["auctionDate"] = NSDate()
                                } else {
                                    let df = DateFormatter()
                                    df.dateFormat = NSXEntry.auctionDateFormat
                                    if let date = df.date(from: auctionDateSpanString) {
                                        dictionary["auctionDate"] = date
                                    }
                                }
                            } else {
                                // Auction location
                                dictionary["auctionLocation"] = contentChildNode.innerHTML
                            }
                        } else if contentChildNode.tagName == "ul", let nodes = contentChildNode.childNodes.array as? [HTMLElement] {
                            for (idx, li) in nodes.enumerated() {
                                let content = li.textContent.trimWhitespaces()
                                if idx == 0 || content.hasSuffix("cc") {
                                    dictionary["displacement"] = content
                                } else if idx == 1 {
                                    dictionary["transmission"] = content
                                } else if idx == 2 {
                                    dictionary["mileage"] = content
                                } else if idx == 3 {
                                    dictionary["gradeString"] = content
                                }
                            }
                        } else if contentChildNode.tagName == "a" {
                            if let href = contentChildNode.attributes["href"] as? String {
                                dictionary["detailPageUrl"] = href
                            }
                        } else if contentChildNode.tagName == "h5" {
                            dictionary["title"] = contentChildNode.textContent.trimWhitespaces()
                        }
                    }
                } else if htmlChild.className == "jas-price", let priceNode = htmlChild.firstChild, let nodes = priceNode.childNodes.array as? [HTMLElement] {
                    for node in nodes {
                        if node.tagName == "a", let href = node.attributes["href"] as? String {
                            dictionary["detailPageUrl"] = href
                        } else if node.tagName == "h6" {
                            dictionary["auctionPriceString"] = node.textContent.trimWhitespaces()
                        }
                    }
                } else if htmlChild.tagName == "a", let imgChild = htmlChild.firstChild as? HTMLElement, let imgUrl = imgChild.attributes["src"] as? String {
                    dictionary["imageUrl"] = imgUrl
                    
                    if let href = htmlChild.attributes["href"] as? String, let urlComponents = URLComponents(string: href), let queryDict = urlComponents.queryDictionary, let uid = queryDict["car_id"] as? String {
                        dictionary["detailPageUrl"] = href
                        dictionary["carId"] = uid
                    }
                }
            }
            
            return dictionary
        }
    }
}


fileprivate extension String {
    func trimWhitespaces() -> String {
        return replacingOccurrences(of: "^\\s+", with: "", options: .regularExpression).replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression).replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
}
