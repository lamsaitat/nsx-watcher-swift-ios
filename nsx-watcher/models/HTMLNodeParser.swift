//
//  HTMLParser.swift
//  nsx-watcher
//
//  Created by Sai Tat Lam on 13/2/19.
//  Copyright © 2019 Henshin Soft Pty Ltd. All rights reserved.
//

import Foundation
import HTMLKit

class HTMLNodeParser {
    
    static func dictionary(from htmlNode: HTMLNode) -> [AnyHashable: Any]? {
        var dictionary = [AnyHashable: Any]()
        guard let childNodes = htmlNode.childNodes.array as? [HTMLElement] else {
            debugPrint("Child nodes not available, not parsing.")
            return dictionary
        }
        
        dictionary["htmlBody"] = htmlNode.outerHTML
        
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
                                let tns = li.childNodes.filter({ cn -> Bool in
                                    return cn is HTMLText
                                }) as! [HTMLText]
                                for tn in tns {
                                    let gradeString = tn.textContent.trimWhitespaces()
                                    if gradeString.hasPrefix("Grade") {
                                        dictionary["gradeString"] = gradeString
                                        break
                                    }
                                }
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

fileprivate extension String {
    /**
     The first revision of the API returned saw some inconsistent whitespaces,
     this method trims excessive whitespaces, as well as leading and trailing
     whitespaces for display OCD.
     */
    func trimWhitespaces() -> String {
        return replacingOccurrences(of: "^\\s+", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
}
