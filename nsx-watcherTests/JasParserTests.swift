//
//  JasParserTests.swift
//  nsx-watcherTests
//
//  Created by Sai Tat Lam on 14/2/19.
//  Copyright © 2019 Henshin Soft Pty Ltd. All rights reserved.
//

import XCTest

class JasParserTests: XCTestCase {
    lazy var bundle: Bundle = {
        return Bundle(for: type(of: self))
    }()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParsingSingleEntry() {
        let url = bundle.url(forResource: "sample-json-response-complete-single-entry", withExtension: "json")!
        let json = try! JSONSerialization.jsonObject(with: Data(contentsOf: url), options: []) as! [AnyHashable: Any]
        
        let carsHtml = json["cars_html"] as! String
        let dicts = JasParser.dictionaries(from: carsHtml)
        
        XCTAssertTrue(dicts.count == 1)
        
    }
    
    func testEmptyInput() {
        let carsHtml = ""
        let dicts = JasParser.dictionaries(from: carsHtml)
        
        XCTAssertTrue(dicts.count == 0)
    }
    
    func testCorruptedEntry() {
        let url = bundle.url(forResource: "sample-json-response-corrupted-entry", withExtension: "json")!
        let json = try! JSONSerialization.jsonObject(with: Data(contentsOf: url), options: []) as! [AnyHashable: Any]
        
        let carsHtml = json["cars_html"] as! String
        let dicts = JasParser.dictionaries(from: carsHtml)
        
        XCTAssertTrue(dicts.count == 1)
    }
}
