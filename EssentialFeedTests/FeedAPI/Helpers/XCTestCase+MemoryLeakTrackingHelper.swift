//
//  MemoryLeakTrackingHelper.swift
//  EssentialFeedTests
//
//  Created by SherifShokry on 02/11/2021.
//

import XCTest


extension XCTestCase {
    
     func trackForMemoryLeaks(_ instance: AnyObject,_ file: StaticString = #filePath ,_ line: UInt = #line){
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance,"Instance should have been deallocated , Potential memory leak",file: file , line: line)
        }
    }
    
}
