//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by SherifShokry on 29/10/2021.
//

import Foundation
import XCTest


class RemoteFeedLoader {
    
    func load(){
        
    }
    
}

class HTTPClient {
    var requestedUrl : URL?
}


class RemoteFeedLoaderTests : XCTestCase {
    
    func test_init_doesNotRequestDataFromURL(){
        let client = HTTPClient()
        let _ = RemoteFeedLoader()
    
        XCTAssertNil(client.requestedUrl)
     }
    
    
}
