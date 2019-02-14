//
//  ListingModelTests.swift
//  nsx-watcherTests
//
//  Created by Sai Tat Lam on 13/2/19.
//  Copyright © 2019 Henshin Soft Pty Ltd. All rights reserved.
//

import XCTest


class ListingModelTests: XCTestCase {

    override func setUp() {
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSingleEntryCreation() {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: "sample-json-response-complete-single-entry", withExtension: "json")!
        let json = try! JSONSerialization.jsonObject(with: Data(contentsOf: url), options: []) as! [AnyHashable: Any]
        
        let carsHtml = json["cars_html"] as! String
        let dicts = JasParser.dictionaries(from: carsHtml)
        
        XCTAssertTrue(dicts.count == 1)
        
        let dictionary = dicts.first!
        let entry = Listing(with: dictionary)
        
        XCTAssertNotNil(entry)
        
        XCTAssertEqual(entry!.carId, "YMFvtbBai4gjUZ")
        XCTAssertEqual(entry!.detailPageUrlString, "http://prestigemotorsport.com.au/auction-vehicle-display/?car_id=YMFvtbBai4gjUZ")
        
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy"
        XCTAssertEqual(df.string(from: entry!.auctionDate), "14-02-2019")
        
        XCTAssertEqual(entry!.auctionLocation, "JU Gunma")
        XCTAssertEqual(entry!.auctionPriceString, "230,000 YEN")
        
        // Optionals
        XCTAssertNotNil(entry!.imageUrl)
        XCTAssertEqual(entry!.imageUrl!, "https://8.ajes.com/imgs/c5At9Pmx48mHVSbCrEbV36xWOo2DM6IOA75Ld5AndBVzDLI&w=320")
    }
}
