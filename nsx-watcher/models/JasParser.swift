//
//  HTMLParser.swift
//  nsx-watcher
//
//  Created by Sai Tat Lam on 13/2/19.
//  Copyright © 2019 Henshin Soft Pty Ltd. All rights reserved.
//

import Foundation
import HTMLKit

class JasParser {
    
    struct Key {
        static let htmlBody = "htmlBody"
        static let auctionDate = "auctionDate"
        static let auctionLocation = "auctionLocation"
        static let auctionPriceString = "auctionPriceString"
        static let detailPageUrl = "detailPageUrl"
        
        static let carId = "carId"
        static let title = "title"
        static let displacement = "displacement"
        static let gradeString = "gradeString"
        static let imageUrl = "imageUrl"
        static let mileage = "mileage"
        static let transmission = "transmission"
    }
    
    static func dictionaries(from carsHtml: String) -> [[AnyHashable: Any]] {
        let parser = HTMLParser(string: carsHtml)
        let context = HTMLElement(tagName: "jas-car-item")
        
        let nodes = parser.parseFragment(withContextElement: context)
        
        var entries = [[AnyHashable: Any]]()
        for node in nodes {
            if let dictionary = dictionary(from: node) {
                entries.append(dictionary)
            }
        }
        return entries
    }
    
    static func dictionary(from htmlNode: HTMLNode) -> [AnyHashable: Any]? {
        var dictionary = [AnyHashable: Any]()
        guard let childNodes = htmlNode.childNodes.array as? [HTMLElement] else {
            debugPrint("Child nodes not available, not parsing.")
            return dictionary
        }
        
        dictionary[Key.htmlBody] = htmlNode.outerHTML
        
        for htmlChild in childNodes {
            if htmlChild.className == "jas-car-item-content", let contentChildNodes = htmlChild.childNodes.array as? [HTMLElement] {
                
                for contentChildNode in contentChildNodes {
                    if contentChildNode.className == "jas-auction-date" {
                        if contentChildNode.outerHTML.contains("Auction Date"), let endNode = contentChildNode.childNodes.lastObject as? HTMLElement {
                            let auctionDateSpanString = endNode.textContent.trimWhitespaces()
                            // Auction date
                            if auctionDateSpanString.lowercased().contains("today") {
                                dictionary[Key.auctionDate] = NSDate()
                            } else {
                                let df = DateFormatter()
                                df.dateFormat = Listing.auctionDateFormat
                                if let date = df.date(from: auctionDateSpanString) {
                                    dictionary[Key.auctionDate] = date
                                }
                            }
                        } else {
                            // Auction location
                            dictionary[Key.auctionLocation] = contentChildNode.innerHTML
                        }
                    } else if contentChildNode.tagName == "ul", let nodes = contentChildNode.childNodes.array as? [HTMLElement] {
                        for (idx, li) in nodes.enumerated() {
                            let content = li.textContent.trimWhitespaces()
                            if idx == 0 || content.hasSuffix("cc") {
                                dictionary[Key.displacement] = content
                            } else if idx == 1 {
                                dictionary[Key.transmission] = content
                            } else if idx == 2 {
                                dictionary[Key.mileage] = content
                            } else if idx == 3 {
                                let tns = li.childNodes.filter({ cn -> Bool in
                                    return cn is HTMLText
                                }) as! [HTMLText]
                                for tn in tns {
                                    let gradeString = tn.textContent.trimWhitespaces()
                                    if gradeString.hasPrefix("Grade") {
                                        dictionary[Key.gradeString] = gradeString
                                        break
                                    }
                                }
                            }
                        }
                    } else if contentChildNode.tagName == "a" {
                        if let href = contentChildNode.attributes["href"] as? String {
                            dictionary[Key.detailPageUrl] = href
                        }
                    } else if contentChildNode.tagName == "h5" {
                        dictionary[Key.title] = contentChildNode.textContent.trimWhitespaces()
                    }
                }
            } else if htmlChild.className == "jas-price", let priceNode = htmlChild.firstChild, let nodes = priceNode.childNodes.array as? [HTMLElement] {
                for node in nodes {
                    if node.tagName == "a", let href = node.attributes["href"] as? String {
                        dictionary[Key.detailPageUrl] = href
                    } else if node.tagName == "h6" {
                        dictionary[Key.auctionPriceString] = node.textContent.trimWhitespaces()
                    }
                }
            } else if htmlChild.tagName == "a", let imgChild = htmlChild.firstChild as? HTMLElement, let imgUrl = imgChild.attributes["src"] as? String {
                dictionary[Key.imageUrl] = imgUrl
                
                if let href = htmlChild.attributes["href"] as? String, let urlComponents = URLComponents(string: href), let queryDict = urlComponents.queryDictionary, let uid = queryDict["car_id"] as? String {
                    dictionary[Key.detailPageUrl] = href
                    dictionary[Key.carId] = uid
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
