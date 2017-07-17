//
//  NSXEntry+CoreDataProperties.swift
//  
//
//  Created by Kelvin Lam on 17/7/17.
//
//

import Foundation
import CoreData


extension NSXEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NSXEntry> {
        return NSFetchRequest<NSXEntry>(entityName: "NSXEntry")
    }

    @NSManaged public var auctionDate: NSDate?
    @NSManaged public var auctionLocation: String?
    @NSManaged public var auctionPriceString: String?
    @NSManaged public var carId: String?
    @NSManaged public var dateAdded: NSDate?
    @NSManaged public var dateModified: NSDate?
    @NSManaged public var detailPageUrl: String?
    @NSManaged public var displacement: String?
    @NSManaged public var gradeString: String?
    @NSManaged public var imageUrl: String?
    @NSManaged public var mileage: String?
    @NSManaged public var title: String?
    @NSManaged public var transmission: String?
    @NSManaged public var htmlBody: String?

}
