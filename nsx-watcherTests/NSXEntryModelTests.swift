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
    }
}
