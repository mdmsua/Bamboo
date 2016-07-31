//
//  PageTests.swift
//  Bamboo
//
//  Created by Dmytro Morozov on 21.06.16.
//  Copyright © 2016 Dmytro Morozov. All rights reserved.
//

import XCTest
import Foundation

class PageTests: XCTestCase {
    
    class Mock: Parsable {
        required init?(_ json: [String: AnyObject]) {
            
        }
    }
    
    func testInitReturnsNilWhenResultsIsNotPresent() {
        let json: [String: AnyObject] = ["foo": []]
        XCTAssertNil(Page<Mock>(json))
    }
    
    func testInitReturnsNilWhenSizeIsNotPresent() {
        let json: [String: AnyObject] = ["results": []]
        XCTAssertNil(Page<Mock>(json))
    }
    
    func testInitReturnsNilWhenSizeIsNotANumber() {
        let json: [String: AnyObject] = ["results": ["size": ""]]
        XCTAssertNil(Page<Mock>(json))
    }
    
    func testInitReturnsNilWhenStartIndexIsNotPresent() {
        let json: [String: AnyObject] = ["results": ["size": 0]]
        XCTAssertNil(Page<Mock>(json))
    }
    
    func testInitReturnsNilWhenStartIndexIsNotANumber() {
        let json: [String: AnyObject] = ["results": ["size": 0, "start-index": ""]]
        XCTAssertNil(Page<Mock>(json))
    }
    
    func testInitReturnsNilWhenMaxResultIsNotPresent() {
        let json: [String: AnyObject] = ["results": ["size": 0, "start-index": 0]]
        XCTAssertNil(Page<Mock>(json))
    }
    
    func testInitReturnsNilWhenMaxResultIsNotANumber() {
        let json: [String: AnyObject] = ["results": ["size": 0, "start-index": 0, "max-result": ""]]
        XCTAssertNil(Page<Mock>(json))
    }
    
    func testInitReturnsNilWhenResultIsNotPresent() {
        let json: [String: AnyObject] = ["results": ["size": 0, "start-index": 0, "max-result": 0]]
        XCTAssertNil(Page<Mock>(json))
    }
    
    func testInitReturnsNilWhenResultIsNotAJson() {
        let json: [String: AnyObject] = ["results": ["size": 0, "start-index": 0, "max-result": 0, "result": ""]]
        XCTAssertNil(Page<Mock>(json))
    }
    
    func testInitSetsCorrectValuesForProperies() {
        let json: [String: AnyObject] = ["results": ["size": 10, "start-index": 7, "max-result": 3, "result": [["foo": "bar", "": ""]]]]
        let page = Page<Mock>(json)
        XCTAssertNotNil(page)
        XCTAssertEqual(page!.size, 10)
        XCTAssertEqual(page!.offset, 7)
        XCTAssertEqual(page!.limit, 3)
        XCTAssertEqual(page!.results.count , 1)
        XCTAssertEqual(page!.current , 2)
    }
    
    func testNextReturnsNil() {
        let json: [String: AnyObject] = ["results": ["size": 10, "start-index": 7, "max-result": 3, "result": [["foo": "bar"]]]]
        let page = Page<Mock>(json)
        XCTAssertNil(page!.next)
    }
    
    func testNextReturnsQueryString() {
        let json: [String: AnyObject] = ["results": ["size": 10, "start-index": 4, "max-result": 3, "result": [["foo": "bar"]]]]
        let page = Page<Mock>(json)
        let next = page!.next
        XCTAssertNotNil(next)
        XCTAssertEqual(next, "max-result=3&start-index=7")
    }
    
    func testHasMoreReturnsTrue() {
        let json: [String: AnyObject] = ["results": ["size": 10, "start-index": 4, "max-result": 3, "result": [["foo": "bar"]]]]
        let page = Page<Mock>(json)
        XCTAssertTrue(page!.hasMore)
    }
    
    func testHasMoreReturnsFalse() {
        let json: [String: AnyObject] = ["results": ["size": 10, "start-index": 9, "max-result": 3, "result": [["foo": "bar"]]]]
        let page = Page<Mock>(json)
        XCTAssertFalse(page!.hasMore)
    }
  
}
